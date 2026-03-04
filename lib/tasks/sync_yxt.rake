namespace :sync_yxt do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_departments_with_no_parent, :sync_1st_level_departments,
    :sync_2nd_level_departments, :sync_3rd_level_departments, :sync_4th_level_departments,
    :sync_5th_level_departments, :sync_position_catalog, :sync_position_grade,
    :sync_yxt_positions, :enable_all_users, :sync_users, :disable_users]

  desc 'Sync department which no parent departments'
  task sync_departments_with_no_parent: :environment do
    puts 'Sync the no parent departments'
    root_departments = yxt_department(nil)
    sync_yxt_departments(root_departments)
  end

  desc 'Sync the 1st level departments'
  task sync_1st_level_departments: :environment do
    puts 'Sync the 1st level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_departments = yxt_department(root_department_ids)
    sync_yxt_departments(first_level_departments)
  end

  desc 'Sync the 2nd level departments'
  task sync_2nd_level_departments: :environment do
    puts 'Sync the 2nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_departments = yxt_department(first_level_department_ids)
    sync_yxt_departments(second_level_departments)
  end

  desc 'Sync the 3rd level departments'
  task sync_3rd_level_departments: :environment do
    puts 'Sync the 3rd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_departments = yxt_department(second_level_department_ids)
    sync_yxt_departments(third_level_departments)
  end

  desc 'Sync the 4nd level departments'
  task sync_4th_level_departments: :environment do
    puts 'Sync the 4nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_departments = yxt_department(third_level_department_ids)
    sync_yxt_departments(fourth_level_departments)
  end

  desc 'Sync the 5nd level departments'
  task sync_5th_level_departments: :environment do
    puts 'Sync the 5nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_department_ids = Department.where(managed_by_department_id: third_level_department_ids).pluck(:id)
    fifth_level_departments = yxt_department(fourth_level_department_ids)
    sync_yxt_departments(fifth_level_departments)
  end

  desc 'Sync the position_catalog to YXT'
  task sync_position_catalog: :environment do
    puts 'Sync the yxt_position_catalogs'
    Position.where.not(functional_category_id: nil)
            .where.not(functional_category: [nil, ''])
            .select(:functional_category_id, :functional_category)
            .distinct
            .order(:functional_category_id, :functional_category)
            .pluck(:functional_category_id, :functional_category)
            .each do |functional_category_id, functional_category|
      puts "position_grade: #{functional_category_id} - #{functional_category}"
      pos = {
        name: functional_category,
        thirdId: functional_category_id
      }
      puts "Yxt.positioncatalogs_sync(pos): #{pos}"
      res = Yxt.positioncatalogs_sync(pos)
      if res.respond_to?(:body)
        puts res.body.to_s
      else
        puts "Yxt.positioncatalogs_sync error response: #{res.inspect}"
      end
    end
  end

  desc 'Sync the position_grade to YXT'
  task sync_position_grade: :environment do
    puts 'Sync the yxt_position_grade'
    Position.where.not(b_postcode: nil)
            .where.not(b_postname: [nil, ''])
            .select(:b_postcode, :b_postname)
            .distinct
            .order(:b_postcode, :b_postname)
            .pluck(:b_postcode, :b_postname)
            .each do |b_postcode, b_postname|
      puts "position_grade: #{b_postcode} - #{b_postname}"
      pos = {
        name: b_postname,
        thirdId: b_postcode
      }
      puts "Yxt.positiongrades_sync(pos): #{pos}"
      res = Yxt.positiongrades_sync(pos)
      if res.respond_to?(:body)
        puts res.body.to_s
      else
        puts "Yxt.positiongrades_sync error response: #{res.inspect}"
      end
    end
  end

  desc 'Sync the position to YXT'
  task sync_yxt_positions: :environment do
    puts 'Sync the yxt_positions'
    Position.order(:id).find_each do |p|
      next if p.users.blank?

      puts "positions: #{p.id}"
      prefix = p.functional_category
      position_name = "#{prefix}-#{p.name}"
      pos = {
        name: position_name,
        thirdId: "#{p.id}",
        catalogThirdId: p.functional_category_id,
        gradeThirdId: p.b_postcode,
        code: p.post_level,
      }
      puts "Yxt.positions_sync(pos): #{pos}"
      res = Yxt.positions_sync(pos)
      puts res.body.to_s
    end
  end

  desc 'Sync the users to YXT'
  task sync_users: :environment do
    puts 'Sync the users'
    User.where(locked_at: nil).order(:id).find_in_batches(batch_size: 100) do |users|
      puts "users: #{users.pluck(:id)}"
      yxt_users = users.collect do |u|
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.position_users.last&.position if main_position.nil?

        dept = if main_position.present? && main_position.department.present?
                 main_position.department
               else
                 u.departments.first
               end

        department_name = if dept.present? && dept.managed_by_department&.name&.end_with?('有限公司')
                            dept.name
                          elsif dept.present?
                            "#{dept.managed_by_department&.name}-#{dept.name}"
                          else
                            puts "User id: #{u.id} name: #{u.username} no department"
                          end

        {
          id: u.id,
          userName: u.yxt_user_name,
          password: '',
          cnName: u&.profile&.chinese_name || u.username,
          userNo: u&.profile&.clerk_code,
          sex: u.profile.present? ? (u.profile.gender ? '男' : '女') : '',
          mobile: u&.profile&.phone,
          isMobileValidated: 1,
          mail: u.email,
          orgOuCode: u.departments.last&.id,
          postionNo: u.yxt_position_id,
          birthday: u&.profile&.birthdate,
          entrytime: u&.profile&.entry_company_date,
          spare1: main_position&.functional_category,
          spare2: main_position&.b_postname,
          spare3: dept&.company_name,
          spare4: department_name,
          spare5: u&.profile&.th_code,
          spare6: u&.profile&.leave_company_date,
          gradeName: u&.profile&.job_level
        }
      end
      res = Yxt.sync_users(yxt_users)
      puts res.body.to_s
    end
  end

  desc 'Disable locked users to YXT'
  task disable_users: :environment do
    puts 'Disable users'
    User.where.not(locked_at: nil).order(:id).find_in_batches(batch_size: 100) do |users|
      puts "users: #{users.pluck(:id)}"
      user_names = users.pluck(:username)
      res = Yxt.disable_users(user_names)
      puts res.body.to_s
    end
  end

  def yxt_department(managed_by_department_ids)
    Department.where(managed_by_department_id: managed_by_department_ids).collect do |d|
      dept_hash = {
        thirdId: d.id.to_s,
        name: d.name,
        description: d.company_name,
        code: d.dept_code
      }

      dept_hash[:parentThirdId] = d.managed_by_department_id.to_s if d.managed_by_department_id.present?

      order_index = d.dept_code.to_s.gsub(/[^0-9]/, '')
      dept_hash[:orderIndex] = order_index.to_i if order_index.present?
      dept_hash
    end
  end

  def sync_yxt_departments(departments)
    departments.each do |department|
      res = Yxt.depts_sync(department)
      puts res.body.to_s
    end
  end

  desc 'Enable all users'
  task enable_all_users: :environment do
    User.all.order(:id).find_in_batches(batch_size: 100) do |users|
      user_names = users.pluck(:username)
      res = Yxt.enable_users(user_names)
      puts res.body.to_s
    end
  end
end
