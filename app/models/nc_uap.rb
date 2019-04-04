class NcUap < ApplicationRecord
  # No corresponding table in the DB.
  self.abstract_class = true
  establish_connection :nc_uap
  def readonly?
    true
  end

  def self.nc_positions
    NcUap.connection.select_rows("
select CONVERT(om_post.postname,'ZHS16GBK', 'UTF8')，om_post.pk_post,
       CONVERT(om_postseries.postseriesname,'ZHS16GBK', 'UTF8')
from om_post
left join om_postseries ON om_post.pk_postseries = om_postseries.pk_postseries
")
  end

  def self.upserts_positions
    positions = NcUap.nc_positions
    positions.each do |p|
      post_name = p[0]
      pk_post = p[1]
      postseriesname = p[2]
      Position.find_or_create_by!(nc_pk_post: pk_post) do |position|
        position.name = post_name
        position.functional_category = postseriesname
      end
    end
  end

  def self.nc_departments
    NcUap.connection.select_rows("
SELECT CONVERT(org_dept.NAME,'ZHS16GBK', 'UTF8'), org_dept.code,
       org_dept.pk_dept, org_dept.pk_fatherorg, CONVERT(org_orgs.name,'ZHS16GBK', 'UTF8'),
       org_dept.enablestate, org_dept.hrcanceled
FROM org_dept INNER JOIN org_orgs on org_dept.pk_org=org_orgs.pk_org
-- WHERE org_dept.enablestate = '2'
--  AND org_dept.hrcanceled = 'N'
ORDER BY org_orgs.code
")
  end

  def self.upserts_departments
    departments = NcUap.nc_departments
    departments.each do |d|
      dept_name = d[0]
      dept_code = d[1]
      pk_dept = d[2]
      pk_fatherorg = d[3]
      company_name = d[4]
      enablestate = d[5]
      hrcanceled = d[6]
      Department.find_or_create_by!(nc_pk_dept: pk_dept) do |department|
        department.name = dept_name
        department.dept_code = dept_code
        department.nc_pk_fatherorg = pk_fatherorg
        department.company_name = company_name
        department.enablestate = enablestate
        department.hrcanceled = hrcanceled
      end
    end
  end

  def self.sync_managed_by_department_with_fatherorg
    Department.where.not(nc_pk_fatherorg: '~').each do |department|
      parent_department = Department.find_by(nc_pk_dept: department.nc_pk_fatherorg)
      department.update(managed_by_department_id: parent_department.id)
    end
  end
end
