require 'test_helper'

class ApiApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'user_info does not fall back to shared kimi key for ai research center users without opencode access' do
    user = users(:user_eric)
    department = Department.create!(name: '天华集团-AI研究中心')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(opencode_api_key: 'user-opencode-key', kimi_api_key: nil)
    sign_in user

    options api_me_url, headers: { 'HTTP_JWT_AUD': 'opencode' }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 'user-opencode-key', payload['opencode_api_key']
    assert_nil payload['kimi_api_key']
  end

  test 'user_info keeps shared kimi fallback for non ai research center users without opencode access' do
    user = users(:user_demo)
    department = Department.create!(name: '普通部门')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(opencode_api_key: 'user-opencode-key', kimi_api_key: nil)
    sign_in user

    options api_me_url, headers: { 'HTTP_JWT_AUD': 'opencode' }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 'user-opencode-key', payload['opencode_api_key']
    assert_equal Rails.application.credentials.kimi_api_key, payload['kimi_api_key']
  end
end
