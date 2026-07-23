require 'test_helper'

class DoorkeeperControllerTest < ActionDispatch::IntegrationTest
  test 'should get token' do
    post user_session_path, as: :json,
                            params: { user: { email: 'eric@cloud-mes.com',
                                              password: '123456' } },
                            headers: { 'HTTP_JWT_AUD': 'oauth2id_test' }
    assert_response :created
    assert_match 'Bearer', @response.header['Authorization']
  end

  test 'should accept bearer token from HTTP_AUTHORIZATION' do
    user = users(:user_eric)
    access_token = Doorkeeper::AccessToken.create!(
      application_id: oauth_applications(:oauth_app_test).id,
      resource_owner_id: user.id,
      scopes: 'public'
    )

    get me_url, headers: { 'HTTP_AUTHORIZATION' => "Bearer #{access_token.token}" }

    assert_response :success
    assert_equal user.id, response.parsed_body['sub']
  end
end
