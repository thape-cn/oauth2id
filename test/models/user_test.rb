require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'User valid' do
    user_eric = users(:user_eric)
    assert user_eric.valid?
    assert_equal user_eric.departments.count, 3
    assert_equal user_eric.positions.count, 2
    assert_equal user_eric.user_sign_in_histories.count, 2
  end

  test 'omniauth never resolves a blank or malformed identity to an employee' do
    assert_nil profiles(:eric_profile).wecom_id

    [nil, '', '  ', false, [], {}, 1].each do |uid|
      auth = OmniAuth::AuthHash.new(provider: 'qiye_web', uid: uid)
      assert_nil User.from_omniauth(auth), "accepted invalid uid #{uid.inspect}"
    end
    assert_nil User.from_omniauth(nil)
  end

  test 'omniauth resolves a verified identity by wecom id' do
    profiles(:eric_profile).update!(wecom_id: 'verified-employee')
    auth = OmniAuth::AuthHash.new(provider: 'qiye_web', uid: 'verified-employee')

    assert_equal users(:user_eric), User.from_omniauth(auth)
  end

  test 'omniauth retains the username fallback for a verified identity' do
    auth = OmniAuth::AuthHash.new(provider: 'qiye_web', uid: users(:user_eric).username)

    assert_equal users(:user_eric), User.from_omniauth(auth)
  end

  test 'omniauth rejects an unknown identity' do
    auth = OmniAuth::AuthHash.new(provider: 'qiye_web', uid: 'unknown-employee')

    assert_nil User.from_omniauth(auth)
  end
end
