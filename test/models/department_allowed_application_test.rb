require 'test_helper'

class DepartmentAllowedApplicationTest < ActiveSupport::TestCase
  test 'Thape IT department department_allowed_applications valid' do
    it_department = departments(:thape_it_department)
    assert it_department.department_allowed_applications.all(&:valid?)
    assert_equal it_department.department_allowed_applications.count, 1
  end

  test 'Oauth app test department_allowed_applications valid' do
    oauth_app_test = oauth_applications(:oauth_app_test)
    assert oauth_app_test.department_allowed_applications.all(&:valid?)
    assert_equal oauth_app_test.department_allowed_applications.count, 2
  end
end
