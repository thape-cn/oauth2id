require 'test_helper'

class JwtsControllerTest < ActionDispatch::IntegrationTest
  test 'should go to sign in page' do
    get jwts_url
    assert_response :redirect
  end

  test 'should show index if sign in' do
    sign_in users(:user_eric)
    get jwts_url
    assert_response :success
  end
end
