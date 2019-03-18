require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'User valid' do
    assert users(:user_eric).valid?
  end
end
