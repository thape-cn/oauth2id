require 'application_system_test_case'

class HomeDashboardsTest < ApplicationSystemTestCase
  test 'visiting the home dashboard' do
    visit root_url

    assert_selector 'h1', text: 'Dashboard'
    assert_selector 'a.btn-dark', text: '登录'
  end
end
