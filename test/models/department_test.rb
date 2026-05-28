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

  test 'NC UAP sync applies top-level department classification rules' do
    architecture = Department.create!(
      name: '天华建筑',
      company_name: '天华建筑-二级分类',
      nc_pk_dept: 'architecture'
    )
    interior = Department.create!(name: '天华室内', company_name: '天华室内-二级分类')
    other = Department.create!(name: '其他', company_name: '其他-二级分类')
    group = Department.create!(name: '天华集团')
    shanghai_tianhua = Department.create!(
      name: '上海天华建筑设计有限公司',
      managed_by_department: architecture
    )
    eid = Department.create!(name: '易爱迪')

    structure_company = Department.create!(
      name: '上海天华结构（北方）事业部',
      company_name: '上海天华结构（北方）事业部',
      managed_by_department: group
    )
    structure_child = Department.create!(
      name: '总经办',
      company_name: '上海天华结构（北方）事业部',
      nc_pk_fatherorg: '~'
    )
    jinan = Department.create!(
      name: '济南天华建筑设计有限公司',
      company_name: '济南天华建筑设计有限公司'
    )
    shanghai_environment = Department.create!(
      name: '上海环境',
      company_name: '上海环境研究中心有限公司',
      nc_pk_fatherorg: 'architecture',
      managed_by_department: architecture
    )
    environment_center = Department.create!(
      name: '上海环境研究中心有限公司',
      company_name: '上海天华建筑设计有限公司',
      managed_by_department: shanghai_tianhua
    )
    easybalance = Department.create!(
      name: '山东易衡节能科技有限公司',
      company_name: '上海天华建筑设计有限公司',
      managed_by_department: shanghai_tianhua
    )
    interior_company = Department.create!(
      name: '爱坤（上海）室内设计咨询有限公司',
      company_name: '爱坤（上海）室内设计咨询有限公司',
      managed_by_department: eid
    )

    NcUap.sync_managed_by_department_with_fatherorg

    assert_equal architecture, structure_company.reload.managed_by_department
    assert_equal structure_company, structure_child.reload.managed_by_department
    assert_equal architecture, jinan.reload.managed_by_department
    assert_equal other, shanghai_environment.reload.managed_by_department
    assert_equal other, environment_center.reload.managed_by_department
    assert_equal other, easybalance.reload.managed_by_department
    assert_equal interior, interior_company.reload.managed_by_department
  end
end
