require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test 'user can update hide agents names from profile settings' do
    user = users(:user_eric)
    sign_in user

    patch setting_url, params: {
      by: 'profile',
      profile: { hide_agents_names: 'agent-one,agent-two' }
    }

    assert_redirected_to profile_setting_url
    assert_equal 'agent-one,agent-two', user.profile.reload.hide_agents_names
  end
end
