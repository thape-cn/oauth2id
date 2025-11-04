require 'application_system_test_case'

class HomeDashboardsTest < ApplicationSystemTestCase
  test 'visiting the home dashboard' do
    user_eric = users(:user_eric)
    login_as user_eric, scope: :user
    visit root_url

    assert_selector 'h1', text: I18n.t('ui.my_application_list')
    find('a.app-nav__item[aria-label="Open Profile Menu"]').click
    assert_selector '.dropdown-item', text: I18n.t('ui.logout')
  end
end
