require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'User valid' do
    user_eric = users(:user_eric)
    assert user_eric.valid?
    assert_equal user_eric.departments.count, 3
    assert_equal user_eric.positions.count, 2
  end
end
