class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should sign in' do
    user_eric = users(:user_eric)

    assert_difference ->{ user_eric.user_sign_in_histories.count }, 1 do
      post user_session_url, params: { user: { email: 'eric@cloud-mes.com',
                                               password: '123456'} }
      assert_response :redirect
    end
  end
end
