require 'test_helper'

class DoorkeeperControllerTest < ActionDispatch::IntegrationTest
  test 'should get token' do
    post oauth_token_url, params: { email: 'eric@cloud-mes.com',
                                    password: '123456',
                                    grant_type: 'password' }
    assert_response :success
    assert_match 'Bearer', JSON.parse(@response.body)['token_type']
  end
end
