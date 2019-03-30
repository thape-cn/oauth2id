require 'test_helper'

class UserSignInHistoryTest < ActiveSupport::TestCase
  test 'UserSignInHistory valid' do
    history_first = user_sign_in_histories(:user_eric_sign_in_history_first)
    assert history_first.valid?
    refute_nil history_first.user
  end
end
