require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'User eric profile valid' do
    eric = users(:user_eric)
    assert eric.profile.valid?
  end
end
