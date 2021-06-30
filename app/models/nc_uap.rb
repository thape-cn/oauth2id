class NcUap < ApplicationRecord
  # No corresponding table in the DB.
  self.abstract_class = true
  establish_connection :nc_uap
  def readonly?
    true
  end

  def self.nc_leaved_users
    NcUap.connection.select_rows("
select a.clerkcode, a.begindate
from nc6337.o2_docquit a
")
  end

  def self.enable_all_users
    User.where("email like '%@thape.com.cn'").where.not(locked_at: nil).update_all(locked_at: nil)
  end

  def self.lock_leaved_users
    users = NcUap.nc_leaved_users
    users.each do |u|
      clerk_code = u[0]
      leaved_company_date = u[1]
      puts "Locking user: #{clerk_code}, #{leaved_company_date}"

      profile = Profile.find_by(clerk_code: clerk_code)
      leave_company_date = Date.parse(leaved_company_date)
      profile.update(leave_company_date: leave_company_date) if profile.present?
      user = profile&.user
      if user.present? && leave_company_date <= Date.today
        user.locked_at = leaved_company_date
        user.save(validate: false)
      end
    end
  end

  def self.nc_users
    NcUap.connection.select_rows("
SELECT bd_psndoc.name, bd_psndoc.SEX, hi_psnjob.clerkcode, bd_psndoc.email, bd_psndoc.mobile,
       hi_psnjob.pk_dept, bd_psndoc.birthdate, hi_psnorg.begindate
  FROM NC6337.bd_psndoc bd_psndoc
INNER JOIN NC6337.hi_psnjob hi_psnjob on bd_psndoc.pk_psndoc = hi_psnjob.pk_psndoc
LEFT JOIN NC6337.hi_psnorg hi_psnorg on hi_psnorg.pk_psndoc = bd_psndoc.pk_psndoc
WHERE hi_psnjob.ismainjob = 'Y'
  AND hi_psnjob.lastflag = 'Y'
  AND hi_psnjob.endflag = 'N'
  AND bd_psndoc.name not in ('AA')
")
  end

  def self.upserts_users
    users = NcUap.nc_users
    users.each do |u|
      chinese_name = u[0]
      sex = u[1]
      clerk_code = u[2]&.strip
      email = u[3]&.strip
      mobile = u[4]&.strip
      pk_dept = u[5]
      birthdate = u[6]
      entry_company_date = u[7]
      puts "Import user: #{chinese_name}"

      email = if email.present? && email.include?('@') && email != '@'
                email
              else
                "#{clerk_code}@thape.com"
              end

      profile = Profile.find_by(clerk_code: clerk_code, chinese_name: chinese_name)
      user = if profile.present?
               user = profile.user
               existing_user = User.find_by email: email.downcase
               if existing_user.blank? || existing_user.email != email.downcase
                 user.update_columns(email: email.downcase, username: email.split('@').first)
                 user
               else
                 existing_user.update_columns(email: email.downcase, username: email.split('@').first)
                 p = existing_user.profile || existing_user.build_profile
                 p.clerk_code = clerk_code
                 p.chinese_name = chinese_name
                 p.save
                 existing_user
               end
             else
               User.find_or_create_by!(email: email.downcase) do |usr|
                 usr.username ||= email.split('@').first == '#' ? clerk_code : email.split('@').first
                 usr.skip_password_validation = true
               end
             end
      user.username ||= email.split('@').first == '#' ? clerk_code : email.split('@').first
      user.skip_password_validation = true
      user.locked_at ||= Time.zone.now unless user.email.end_with?('@thape.com.cn')
      user.save

      profile = user.profile || user.build_profile
      profile.chinese_name = chinese_name
      profile.gender = (sex == 2 ? 0 : sex) # Femail is 0 in oauth2id
      profile.clerk_code = clerk_code
      profile.phone = mobile
      profile.birthdate = birthdate
      profile.entry_company_date = entry_company_date
      profile.save

      user_department = Department.find_by!(nc_pk_dept: pk_dept)
      DepartmentUser.find_or_create_by!(user_id: user.id, department_id: user_department.id)
    end
  end

  def self.nc_position_users
    NcUap.connection.select_rows("
SELECT pncode, ismainjob, post_id, postlevel, classify_post
FROM NC6337.V_PSNDOC_POST
WHERE post_id != '~'
")
  end

  def self.upserts_position_users
    position_users = NcUap.nc_position_users
    position_users.each do |pu|
      clerk_code = pu[0]&.strip
      user = Profile.find_by(clerk_code: clerk_code)&.user
      next if user.nil?

      is_main_job = (pu[1]&.strip == 'Y')

      post_id = pu[2]&.strip
      position = Position.find_by(nc_pk_post: post_id)
      next if position.nil?

      post_level = pu[3]&.strip
      classify_post = pu[4]&.strip

      position_user = PositionUser.find_or_create_by!(user_id: user.id, position_id: position.id) do |p|
        p.main_position = is_main_job
        p.post_level = post_level
        p.job_type_code = classify_post
      end
      position_user.main_position = is_main_job
      position_user.post_level = post_level
      position_user.job_type_code = classify_post
      position_user.save
    end
  end

  def self.nc_user_majors
    NcUap.connection.select_rows("
SELECT hi_psnjob.clerkcode, bd_defdoc.code major_code, bd_defdoc.name major_name
FROM NC6337.bd_psndoc bd_psndoc
INNER JOIN NC6337.hi_psnjob hi_psnjob ON bd_psndoc.pk_psndoc = hi_psnjob.pk_psndoc
INNER JOIN NC6337.Hi_Psndoc_Glbdef3 Hi_Psndoc_Glbdef3 ON Hi_Psndoc_Glbdef3.pk_psndoc = bd_psndoc.pk_psndoc
INNER JOIN NC6337.BD_defdoc bd_defdoc ON bd_defdoc.pk_defdoc = Hi_Psndoc_Glbdef3.Glbdef1
WHERE hi_psnjob.ismainjob = 'Y'
  AND hi_psnjob.lastflag = 'Y'
  AND hi_psnjob.endflag = 'N'
  AND Hi_Psndoc_Glbdef3.dr = '0'
  AND bd_defdoc.pk_defdoclist = '1001A7100000000022C5'
")
  end

  def self.upserts_user_majors
    user_majors = NcUap.nc_user_majors
    user_majors.each do |pu|
      clerk_code = pu[0]&.strip
      major_code = pu[1]&.strip
      major_name = pu[2]&.strip
      profile = Profile.find_by(clerk_code: clerk_code)
      next if profile.nil?

      profile.update(major_code: major_code, major_name: major_name)
    end
  end

  def self.set_profile_job_level
    User.all.each do |user|
      next if user.profile.nil?

      job_levels = user.position_users.collect { |p| p.post_level.to_i }
      user.profile.update(job_level: job_levels.max)
    end
  end

  def self.nc_positions
    NcUap.connection.select_rows("
select om_post.postname，om_post.pk_post, om_postseries.postseriesname, om_post.pk_DEPT,
       om_post.pk_poststd, om_post1.postcode as b_postcode, om_post1.postname as b_postname
from NC6337.om_post om_post
inner join NC6337.om_postseries om_postseries ON om_post.pk_postseries = om_postseries.pk_postseries
inner join NC6337.om_post om_post1 ON om_post.pk_poststd = om_post1.pk_post
where om_post.enablestate = '2'
  and om_post.pk_post in (select distinct pk_post from nc6337.hi_psnjob where endflag= 'N')
")
  end

  def self.upserts_positions
    positions = NcUap.nc_positions
    positions.each do |p|
      post_name = p[0]
      pk_post = p[1]
      postseriesname = p[2]
      pk_dept = p[3]
      pk_poststd = p[4]
      b_postcode = p[5]
      b_postname = p[6]

      position = Position.find_or_create_by!(nc_pk_post: pk_post) do |pos|
        pos.name = post_name
        pos.functional_category = postseriesname
        pos.nc_pk_post = pk_post
        pos.department_id = Department.find_by(nc_pk_dept: pk_dept)&.id
        pos.pk_poststd = pk_poststd
        pos.b_postcode = b_postcode
        pos.b_postname = b_postname
      end
      position.name = post_name
      position.functional_category = postseriesname
      position.nc_pk_post = pk_post
      position.department_id = Department.find_by(nc_pk_dept: pk_dept)&.id
      position.pk_poststd = pk_poststd
      position.b_postcode = b_postcode
      position.b_postname = b_postname
      position.save
    end
  end

  def self.nc_departments
    NcUap.connection.select_rows("
SELECT distinct org_dept.NAME, org_dept.code,
       org_dept.pk_dept, org_orgs.pk_org, org_dept.pk_fatherorg, org_orgs.name, org_orgs.code,
       org_dept.enablestate, org_dept.hrcanceled,
       decode(org_dept.glbdef1, '1001A710000000001PQE', '职能', '1001A710000000001PQF', '生产') dept_category
FROM NC6337.org_dept org_dept
INNER JOIN NC6337.org_orgs org_orgs on org_dept.pk_org = org_orgs.pk_org
INNER JOIN NC6337.bd_psndoc on bd_psndoc.pk_ORG = org_orgs.pk_org
INNER JOIN NC6337.hi_psnjob hi_psnjob on bd_psndoc.pk_psndoc = hi_psnjob.pk_psndoc
WHERE org_dept.enablestate = '2'
  AND org_dept.hrcanceled = 'N'
  AND hi_psnjob.ismainjob = 'Y'
  AND hi_psnjob.lastflag = 'Y'
  AND hi_psnjob.endflag = 'N'
")
  end

  def self.upserts_departments
    departments = NcUap.nc_departments
    departments.each do |d|
      dept_name = d[0]
      dept_code = d[1]
      pk_dept = d[2]
      pk_org = d[3]
      pk_fatherorg = d[4]
      company_name = d[5]
      company_code = d[6]
      enablestate = d[7]
      hrcanceled = d[8]
      dept_category = d[9]
      department = Department.find_or_create_by!(nc_pk_dept: pk_dept) do |department|
        department.name = dept_name
        department.dept_code = dept_code
        department.nc_pk_fatherorg = pk_fatherorg
        department.company_name = company_name
        department.company_code = company_code
        department.enablestate = enablestate
        department.hrcanceled = hrcanceled
        department.dept_category = dept_category
      end
      department.name = dept_name
      department.dept_code = dept_code
      department.nc_pk_fatherorg = pk_fatherorg
      department.company_name = company_name
      department.company_code = company_code
      department.enablestate = enablestate
      department.hrcanceled = hrcanceled
      department.dept_category = dept_category
      department.save
    end
  end

  def self.sync_managed_by_department_with_fatherorg
    Department.all.each do |department|
      parent_department = Department.find_by(nc_pk_dept: department.nc_pk_fatherorg)
      if parent_department.blank? && department.company_name != '天华集团' # pk_org: '0001A110000000007I8I'
        parent_department = Department.find_by(name: department.company_name)
      end
      if department.id != parent_department&.id
        department.update(managed_by_department_id: parent_department&.id)
      end
    end
  end

  def self.upserts_orgs_as_departments_all
    org_depts = NcUap.nc_orgs_all
    org_depts.each do |d|
      org_name = d[0]
      org_code = d[1]
      pk_org = d[2]
      pk_fatherorg = d[3] == '0001A110000000007I8I' ? nil : d[3]
      company_name = d[4]
      department = Department.find_or_create_by!(nc_pk_dept: pk_org) do |department|
        department.name = org_name
        department.dept_code = org_code
        department.nc_pk_fatherorg = pk_fatherorg
        department.company_name = company_name
        department.company_code = org_code
        department.enablestate = '2'
      end
      department.name = org_name
      department.dept_code = org_code
      department.nc_pk_fatherorg = pk_fatherorg
      department.company_name = company_name
      department.company_code = org_code
      department.enablestate = '2'
      department.save
    end
  end

  def self.nc_orgs_all
    NcUap.connection.select_rows("
SELECT V_ORGS_ALL.name, V_ORGS_ALL.code, V_ORGS_ALL.pk_ORG, V_ORGS_ALL.pk_FATHERORG, V_ORGS_ALL.DEF1
FROM NC6337.V_ORGS_ALL V_ORGS_ALL
where V_ORGS_ALL.pk_org != '0001A110000000007I8I'
")
  end

  def self.upserts_missing_orgs_as_departments
    org_depts = NcUap.nc_orgs_missing
    org_depts.each do |d|
      org_name = d[0]
      org_code = d[1]
      pk_org = d[2]
      pk_fatherorg = d[3] == '0001A110000000007I8I' ? nil : d[3]
      enablestate = d[4]
      department = Department.find_or_create_by!(nc_pk_dept: pk_org) do |department|
        department.name = org_name
        department.dept_code = org_code
        department.nc_pk_fatherorg = pk_fatherorg
        department.company_name = org_name
        department.company_code = org_code
        department.enablestate = enablestate
      end
      department.name = org_name
      department.dept_code = org_code
      department.nc_pk_fatherorg = pk_fatherorg
      department.company_name = org_name
      department.company_code = org_code
      department.enablestate = enablestate
      department.save
    end
  end

  def self.nc_orgs_missing
    NcUap.connection.select_rows("
select org_orgs.name, org_orgs.code, org_orgs.pk_org, org_orgs.pk_fatherorg, org_orgs.enablestate
from NC6337.org_orgs org_orgs
where org_orgs.pk_org != '0001A110000000007I8I'
  and org_orgs.enablestate = '2'
  and org_orgs.name in ('#{self.get_need_import_company_name.join("','")}')
")
  end

  private

  def self.get_need_import_company_name
    Department.where(nc_pk_fatherorg: '~', managed_by_department_id: nil).pluck(:company_name) - ['天华集团']
  end
end
