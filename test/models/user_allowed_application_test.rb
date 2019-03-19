require 'test_helper'

class UserAllowedApplicationTest < ActiveSupport::TestCase
  test "Eric's user_allowed_applications valid" do
    eric = users(:user_eric)
    assert eric.user_allowed_applications.all(&:valid?)
    assert_equal eric.user_allowed_applications.count, 3
  end

  test "oauth_app_test's user_allowed_applications valid" do
    oauth_app_test = oauth_applications(:oauth_app_test)
    assert oauth_app_test.user_allowed_applications.all(&:valid?)
    assert_equal oauth_app_test.user_allowed_applications.count, 2
  end
end
