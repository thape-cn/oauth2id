class NcUap < ApplicationRecord
  # No corresponding table in the DB.
  self.abstract_class = true
  establish_connection :nc_uap
  def readonly?
    true
  end

  def self.nc_users
    NcUap.connection.select_rows("
select bd_psndoc.name, bd_psndoc.SEX, hi_psnjob.clerkcode, bd_psndoc.email,
       hi_psnjob.pk_dept, hi_psnjob.pk_post, om_joblevel.name, bd_psndoc.birthdate, hi_psnorg.begindate
from NC6337.bd_psndoc bd_psndoc
inner join NC6337.hi_psnjob hi_psnjob on bd_psndoc.pk_psndoc = hi_psnjob.pk_psndoc
left join NC6337.om_joblevel om_joblevel on om_joblevel.pk_joblevel = hi_psnjob.pk_jobgrade
left join NC6337.hi_psnorg hi_psnorg on hi_psnorg.pk_psndoc = bd_psndoc.pk_psndoc
where hi_psnjob.ismainjob = 'Y'
  and hi_psnjob.lastflag = 'Y'
  and hi_psnjob.endflag = 'N'
  and bd_psndoc.email is not null
  and bd_psndoc.email like '%@thape.com.cn'
  and hi_psnjob.clerkcode not in ('002541','012096')
  and bd_psndoc.email not in ('yangxiao@thape.com.cn ')
  and bd_psndoc.email not in ('xieyong@','xiezhipeng@','**','#n/a','#N/A','#','##','###','####','#####','####cn','*','/','0','111','1111','123','123456','213412341234','6699','=')

")
  end

  def self.upserts_users
    users = NcUap.nc_users
    users.each do |u|
      chinese_name = u[0]
      sex = u[1]
      clerk_code = u[2]
      email = u[3]
      pk_dept = u[4]
      pk_post = u[5]
      job_level = u[6]
      birthdate = u[7]
      entry_company_date = u[8]
      puts "Import user: #{chinese_name}"
      user = User.find_or_create_by!(email: email.downcase) do |user|
        user.username ||= email.split('@').first == '#' ? clerk_code : email.split('@').first
        user.skip_password_validation = true
        byebug if !user.valid?
      end
      profile = user.profile || user.build_profile
      profile.chinese_name = chinese_name
      profile.gender = (sex == 2 ? 0 : sex) # Femail is 0 in oauth2id
      profile.clerk_code = clerk_code
      profile.job_level = job_level
      profile.birthdate = birthdate
      profile.entry_company_date = entry_company_date
      profile.save

      user_department = Department.find_by(nc_pk_dept: pk_dept)
      DepartmentUser.find_or_create_by!(user_id: user.id, department_id: user_department.id)

      if pk_post != '~'
        user_position = Position.find_by(nc_pk_post: pk_post)
        PositionUser.find_or_create_by!(user_id: user.id, position_id: user_position.id, main_position: true)
      end
    end
  end

  def self.nc_positions
    NcUap.connection.select_rows("
select om_post.postname，om_post.pk_post, om_postseries.postseriesname
from NC6337.om_post om_post
left join NC6337.om_postseries om_postseries ON om_post.pk_postseries = om_postseries.pk_postseries
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
SELECT org_dept.NAME, org_dept.code,
       org_dept.pk_dept, org_dept.pk_fatherorg, org_orgs.name,
       org_dept.enablestate, org_dept.hrcanceled
FROM NC6337.org_dept org_dept
INNER JOIN NC6337.org_orgs org_orgs on org_dept.pk_org=org_orgs.pk_org
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
