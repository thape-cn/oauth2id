require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  test 'Department valid' do
    thape_architectural_design_group = departments(:thape_architectural_design_group)
    assert thape_architectural_design_group.valid?
    assert_equal thape_architectural_design_group.users.count, 60
    assert_equal thape_architectural_design_group.managed_departments.count, 3
    revert_department = thape_architectural_design_group.managed_departments.first
    assert_equal revert_department.managed_by_department.id, thape_architectural_design_group.id
  end
end
