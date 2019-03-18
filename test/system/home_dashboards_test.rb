require 'application_system_test_case'

class HomeDashboardsTest < ApplicationSystemTestCase
  test 'visiting the home dashboard' do
    visit root_url

    assert_selector 'h1', text: I18n.t('ui.my_application_list')
    assert_selector 'a.btn-dark', text: I18n.t('user.sign_in')
  end
end
