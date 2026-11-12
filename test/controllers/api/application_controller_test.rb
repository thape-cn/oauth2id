require 'test_helper'
require 'minitest/mock'

class ApiApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile_api_keys = %i[opencode_api_key kimi_api_key siliconflow_cn_api_key moonshot_api_key
                           exa_api_key deepseek_api_key cerebras_api_key].index_with { |key| "user-#{key}" }
    @shared_api_keys = (@profile_api_keys.keys - [:kimi_api_key] + [:vipai_api_key]).index_with { |key| "shared-#{key}" }
    @shared_kimi_api_keys = %w[shared-kimi-key-1 shared-kimi-key-2 shared-kimi-key-3]
  end

  test 'user_info rejects requests without a jwt' do
    options api_me_url, headers: { HTTP_JWT_AUD: 'opencode' }

    assert_response :unauthorized
    assert_empty response.body
  end

  test 'user_info rejects session cookies without a jwt' do
    sign_in_with_cookie users(:user_eric)

    options api_me_url, headers: { HTTP_JWT_AUD: 'opencode' }

    assert_response :unauthorized
    assert_empty response.body
  end

  test 'user_info rejects an invalid jwt even with a session cookie' do
    sign_in_with_cookie users(:user_eric)

    options api_me_url, headers: { HTTP_AUTHORIZATION: 'Bearer invalid', HTTP_JWT_AUD: 'opencode' }

    assert_response :unauthorized
    assert_empty response.body
  end

  test 'user_info rejects an expired jwt even with a session cookie' do
    user = users(:user_eric)
    sign_in_with_cookie user
    headers = travel_to(91.days.ago) { jwt_headers(user) }

    options api_me_url, headers: headers

    assert_response :unauthorized
  end

  test 'user_info rejects a revoked jwt even with a session cookie' do
    user = users(:user_eric)
    sign_in_with_cookie user
    headers = jwt_headers(user)
    user.allowlisted_jwts.destroy_all

    options api_me_url, headers: headers

    assert_response :unauthorized
  end

  test 'user_info rejects a jwt with the wrong audience even with a session cookie' do
    user = users(:user_eric)
    sign_in_with_cookie user
    headers = jwt_headers(user).merge(HTTP_JWT_AUD: 'CAD')

    options api_me_url, headers: headers

    assert_response :unauthorized
  end

  test 'user_info uses the jwt user when the session cookie belongs to another user' do
    sign_in_with_cookie users(:user_eric)
    user = users(:user_demo)

    options api_me_url, headers: jwt_headers(user)

    assert_response :success
    assert_equal user.email, response.parsed_body['email']
  end

  test 'user_info accepts a jwt without establishing a session' do
    user = users(:user_eric)

    options api_me_url, headers: jwt_headers(user)

    assert_response :success
    assert_equal user.email, response.parsed_body['email']
    assert_nil cookies[Rails.application.config.session_options[:key]]

    options api_me_url, headers: { HTTP_JWT_AUD: 'opencode' }

    assert_response :unauthorized
  end

  %w[opencode CAD].each do |audience|
    test "user_info returns no api keys without access for #{audience}" do
      request_user_info(users(:user_demo), audience: audience)

      assert_no_api_keys
      assert_equal 'No Zen', response.parsed_body['clerk_code']
      assert_equal ['bid-assistant', '7777'], response.parsed_body['hide_agents']
    end

    test "user_info returns only profile api keys without access for #{audience}" do
      user = users(:user_demo)
      user.profile.update!(@profile_api_keys)

      request_user_info(user, audience: audience)

      @profile_api_keys.except(:kimi_api_key).each do |key, value|
        assert_equal value, response.parsed_body[key.to_s], key.to_s
      end
      assert_equal [@profile_api_keys[:kimi_api_key]], response.parsed_body['kimi_api_keys']
      assert_nil response.parsed_body['vipai_api_key']
      assert_equal "🔑#{user.profile.clerk_code}", response.parsed_body['clerk_code']
    end

    test "user_info returns shared api keys with access for #{audience}" do
      user = users(:user_eric)
      allow_opencode_access(user)

      request_user_info(user, audience: audience)

      @shared_api_keys.each do |key, value|
        assert_equal value, response.parsed_body[key.to_s], key.to_s
      end
      assert_equal @shared_kimi_api_keys, response.parsed_body['kimi_api_keys']
      assert_equal user.profile.clerk_code, response.parsed_body['clerk_code']
    end

    test "user_info returns no shared api keys with disabled access for #{audience}" do
      user = users(:user_eric)
      allow_opencode_access(user, enable: false)

      request_user_info(user, audience: audience)

      assert_no_api_keys
    end
  end

  test 'user_info prefers profile api keys over shared api keys with access' do
    user = users(:user_eric)
    allow_opencode_access(user)
    user.profile.update!(@profile_api_keys)

    request_user_info(user)

    @profile_api_keys.except(:kimi_api_key).each do |key, value|
      assert_equal value, response.parsed_body[key.to_s], key.to_s
    end
    assert_equal [@profile_api_keys[:kimi_api_key], *@shared_kimi_api_keys.drop(1)], response.parsed_body['kimi_api_keys']
    assert_equal @shared_api_keys[:vipai_api_key], response.parsed_body['vipai_api_key']
  end

  test 'user_info returns no shared api keys for other audiences even with an enabled application' do
    user = users(:user_eric)
    allow_opencode_access(user)

    request_user_info(user, audience: 'other')

    assert_no_api_keys
  end

  test 'user_info returns no api keys for blank profile keys without access' do
    user = users(:user_demo)
    user.profile.update!(@profile_api_keys.transform_values { '  ' })

    request_user_info(user)

    assert_no_api_keys
  end

  test 'user_info returns no api keys without a profile or access' do
    user = users(:user_demo)
    user.profile.destroy!

    request_user_info(user)

    assert_no_api_keys
    assert_equal user.username, response.parsed_body['chinese_name']
  end

  test 'user_info returns only profile api keys and hides agents for ai research center users without access' do
    user = users(:user_eric)
    department = Department.create!(name: '天华集团-AI研究中心')
    user.position_users.find_by(main_position: true).position.update!(department: department)
    user.profile.update!(kimi_api_key: 'user-kimi-key', deepseek_api_key: 'user-deepseek-key',
                         hide_agents_names: ' bid-assistant, 7777, ,custom-agent ')

    request_user_info(user)

    assert_equal ['user-kimi-key'], response.parsed_body['kimi_api_keys']
    assert_equal 'user-deepseek-key', response.parsed_body['deepseek_api_key']
    @shared_api_keys.except(:deepseek_api_key).each_key do |key|
      assert_nil response.parsed_body[key.to_s], key.to_s
    end
    assert_equal ['bid-assistant', '7777', 'custom-agent', 'scheme-assistant'], response.parsed_body['hide_agents']
  end

  private

  def sign_in_with_cookie(user)
    sign_in user
    get jwts_url
    assert_response :success
    assert cookies[Rails.application.config.session_options[:key]].present?
  end

  def jwt_headers(user, audience: 'opencode')
    token, payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, audience)
    user.on_jwt_dispatch(token, payload)
    { HTTP_AUTHORIZATION: "Bearer #{token}", HTTP_JWT_AUD: audience }
  end

  def allow_opencode_access(user, enable: true)
    application = DoorkeeperApplication.create!(id: 60, name: 'opencode', redirect_uri: 'https://example.com/callback')
    user.user_allowed_applications.create!(oauth_application: application, enable: enable)
  end

  def request_user_info(user, audience: 'opencode')
    credentials = ActiveSupport::OrderedOptions.new.merge!(Rails.application.credentials.config).merge!(@shared_api_keys)
    @shared_kimi_api_keys.each_with_index do |key, index|
      credentials["kimi_api_key_#{index + 1}"] = key
    end

    Rails.application.stub(:credentials, -> { credentials }) do
      options api_me_url, headers: jwt_headers(user, audience: audience)
    end

    assert_response :success
  end

  def assert_no_api_keys
    @shared_api_keys.each_key do |key|
      assert_nil response.parsed_body[key.to_s], key.to_s
    end
    assert_empty response.parsed_body['kimi_api_keys']
  end
end
