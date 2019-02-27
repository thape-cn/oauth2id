require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'User valid' do
    assert users(:eric).valid?
  end
end
