require 'test_helper'

class VendorsControllerTest < ActionDispatch::IntegrationTest
  test 'should go to sign in page' do
    get vendors_url
    assert_response :redirect
  end

  test 'should show index if sign in' do
    sign_in users(:eric)
    get vendors_url
    assert_response :success
  end
end
