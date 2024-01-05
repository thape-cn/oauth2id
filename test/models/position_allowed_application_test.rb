require 'test_helper'

class PositionAllowedApplicationTest < ActiveSupport::TestCase
  test 'Position Rails developer position_allowed_applications valid' do
    rails_developer = positions(:position_rails_developer)
    assert rails_developer.position_allowed_applications.all(&:valid?)
    assert_equal rails_developer.position_allowed_applications.count, 1
  end

  test 'Oauth app test position_allowed_applications valid' do
    oauth_app_test = oauth_applications(:oauth_app_test)
    assert oauth_app_test.position_allowed_applications.all(&:valid?)
    assert_equal oauth_app_test.position_allowed_applications.count, 2
  end
end
