class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should sign in' do
    user_eric = users(:user_eric)

    assert_difference -> { user_eric.user_sign_in_histories.count }, 1 do
      post user_session_url, as: :json,
                             params: { user: { email: 'eric@cloud-mes.com',
                                               password: '123456' } },
                             headers: { 'HTTP_JWT_AUD': 'oauth2id_test' }
      assert_response :created
    end
  end
end
