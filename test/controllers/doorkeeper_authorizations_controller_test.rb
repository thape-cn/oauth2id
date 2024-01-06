require 'test_helper'

class DoorkeeperAuthorizationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in users(:user_eric)
  end

  test 'should show new authorize title' do
    test_doorkeeper_application = oauth_applications(:oauth_app_test)
    get oauth_authorization_url, params: { client_id: test_doorkeeper_application.uid,
                                           redirect_uri: test_doorkeeper_application.redirect_uri,
                                           response_type: 'code',
                                           scope: 'public' }
    assert_response :success
    assert_match I18n.t('doorkeeper.authorizations.new.title'), @response.body
  end

  test 'should give back callback code if user approve access' do
    test_doorkeeper_application = oauth_applications(:oauth_app_test)
    post oauth_authorization_url, params: { client_id: test_doorkeeper_application.uid,
                                            redirect_uri: test_doorkeeper_application.redirect_uri,
                                            response_type: 'code',
                                            scope: 'public' }
    assert_response :redirect
    assert_match Doorkeeper::AccessGrant.last.token, response.headers['location'].split('=')[1]
  end

  test 'should access_denied if user denied access' do
    test_doorkeeper_application = oauth_applications(:oauth_app_test)
    delete oauth_authorization_url, params: { client_id: test_doorkeeper_application.uid,
                                              redirect_uri: test_doorkeeper_application.redirect_uri,
                                              response_type: 'code',
                                              scope: 'public' }
    assert_response :redirect
    assert_includes response.headers['location'], 'error=access_denied'
  end
end
