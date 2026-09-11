require 'test_helper'
require 'minitest/mock'

class ApiApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shared_kimi_api_keys = %w[shared-kimi-key-1 shared-kimi-key-2 shared-kimi-key-3 shared-kimi-key-4]
  end

  test 'user_info does not fall back to shared ai keys for ai research center users without opencode access' do
    user = users(:user_eric)
    department = Department.create!(name: '天华集团-AI研究中心')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(opencode_api_key: 'user-opencode-key', kimi_api_key: nil, deepseek_api_key: nil,
                         hide_agents_names: ' bid-assistant, 7777, ,custom-agent ')
    sign_in user

    request_user_info

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 'user-opencode-key', payload['opencode_api_key']
    assert_equal [], payload['kimi_api_keys']
    assert_nil payload['kimi_api_key_1']
    assert_nil payload['kimi_api_key_2']
    assert_nil payload['deepseek_api_key']
    assert_equal ['bid-assistant', '7777', 'custom-agent', 'scheme-assistant'], payload['hide_agents']
  end

  test 'user_info keeps shared ai fallbacks for non ai research center users without opencode access' do
    user = users(:user_demo)
    department = Department.create!(name: '普通部门')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(opencode_api_key: 'user-opencode-key', kimi_api_key: nil, deepseek_api_key: nil)
    sign_in user

    request_user_info

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 'user-opencode-key', payload['opencode_api_key']
    assert_equal @shared_kimi_api_keys, payload['kimi_api_keys']
    assert_equal 'shared-kimi-key-1', payload['kimi_api_key_1']
    assert_equal 'shared-kimi-key-2', payload['kimi_api_key_2']
    assert_equal Rails.application.credentials.deepseek_api_key, payload['deepseek_api_key']
    assert_equal ['bid-assistant', '7777'], payload['hide_agents']
  end

  test 'user_info returns all four kimi keys for users with opencode access' do
    user = users(:user_eric)
    application = DoorkeeperApplication.create!(id: 60, name: 'opencode', redirect_uri: 'https://example.com/callback')
    user.user_allowed_applications.create!(oauth_application: application, enable: true)
    user.profile.update!(kimi_api_key: nil)
    sign_in user

    request_user_info

    assert_response :success
    assert_equal @shared_kimi_api_keys, response.parsed_body['kimi_api_keys']
    assert_equal 'shared-kimi-key-1', response.parsed_body['kimi_api_key_1']
    assert_equal 'shared-kimi-key-2', response.parsed_body['kimi_api_key_2']
  end

  test 'user_info replaces the first shared kimi key with the profile key' do
    user = users(:user_demo)
    department = Department.create!(name: '普通部门')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(kimi_api_key: 'user-kimi-key')
    sign_in user

    request_user_info

    assert_response :success
    assert_equal ['user-kimi-key', *@shared_kimi_api_keys.drop(1)], response.parsed_body['kimi_api_keys']
    assert_equal 'user-kimi-key', response.parsed_body['kimi_api_key_1']
    assert_equal 'shared-kimi-key-2', response.parsed_body['kimi_api_key_2']
  end

  test 'user_info returns only the profile kimi key for ai research center users without opencode access' do
    user = users(:user_eric)
    department = Department.create!(name: '天华集团-AI研究中心')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(kimi_api_key: 'user-kimi-key')
    sign_in user

    request_user_info

    assert_response :success
    assert_equal ['user-kimi-key'], response.parsed_body['kimi_api_keys']
    assert_equal 'user-kimi-key', response.parsed_body['kimi_api_key_1']
    assert_equal 'user-kimi-key', response.parsed_body['kimi_api_key_2']
  end

  private

  def request_user_info
    credentials = ActiveSupport::OrderedOptions.new.merge!(Rails.application.credentials.config)
    @shared_kimi_api_keys.each_with_index do |key, index|
      credentials["kimi_api_key_#{index + 1}"] = key
    end

    Rails.application.stub(:credentials, -> { credentials }) do
      options api_me_url, headers: { 'HTTP_JWT_AUD': 'opencode' }
    end

    refute response.parsed_body.key?('kimi_api_key')
    assert response.parsed_body.key?('kimi_api_key_1')
    assert response.parsed_body.key?('kimi_api_key_2')
  end
end
