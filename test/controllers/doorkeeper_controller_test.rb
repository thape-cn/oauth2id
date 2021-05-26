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
end
