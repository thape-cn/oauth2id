require 'test_helper'

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  %i[get post].each do |method|
    test "forged #{method} WeCom callback cannot create an authenticated session" do
      assert_no_difference ['UserSignInHistory.count', 'AllowlistedJwt.count'] do
        public_send(method, user_qiye_web_omniauth_callback_path,
                    params: { code: 'forged-code', state: 'forged-state' })
      end

      assert_response :redirect
      assert_equal :csrf_detected, request.env['omniauth.error.type']
      assert_nil request.env['omniauth.auth']
      assert_nil request.env['warden'].user

      get root_path
      assert_redirected_to new_user_session_path
      get jwts_path
      assert_redirected_to new_user_session_path
    end
  end
end
