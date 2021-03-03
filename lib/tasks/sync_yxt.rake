namespace :sync_yxt do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_departments_with_no_parent, :sync_1st_level_departments,
    :sync_2nd_level_departments, :sync_3rd_level_departments, :sync_4nd_level_departments,
    :sync_5nd_level_departments, :sync_positions, :enable_all_users, :sync_users, :disable_users]

  desc 'Sync department which no parent departments'
  task sync_departments_with_no_parent: :environment do
    puts 'Sync the no parent departments'
    root_departments = yxt_department(nil)
    res = Yxt.sync_ous(root_departments)
    puts res.body.to_s
  end

  desc 'Sync the 1st level departments'
  task sync_1st_level_departments: :environment do
    puts 'Sync the 1st level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_departments = yxt_department(root_department_ids)
    res = Yxt.sync_ous(first_level_departments)
    puts res.body.to_s
  end

  desc 'Sync the 2nd level departments'
  task sync_2nd_level_departments: :environment do
    puts 'Sync the 2nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_departments = yxt_department(first_level_department_ids)
    res = Yxt.sync_ous(second_level_departments)
    puts res.body.to_s
  end

  desc 'Sync the 3rd level departments'
  task sync_3rd_level_departments: :environment do
    puts 'Sync the 3rd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_departments = yxt_department(second_level_department_ids)
    res = Yxt.sync_ous(third_level_departments)
    puts res.body.to_s
  end

  desc 'Sync the 4nd level departments'
  task sync_4nd_level_departments: :environment do
    puts 'Sync the 4nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_departments = yxt_department(third_level_department_ids)
    res = Yxt.sync_ous(fourth_level_departments)
    puts res.body.to_s
  end

  desc 'Sync the 5nd level departments'
  task sync_5nd_level_departments: :environment do
    puts 'Sync the 5nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_department_ids = Department.where(managed_by_department_id: third_level_department_ids).pluck(:id)
    fifth_level_departments = yxt_department(fourth_level_department_ids)
    res = Yxt.sync_ous(fifth_level_departments)
    puts res.body.to_s
  end

  desc 'Sync the position to YXT'
  task sync_positions: :environment do
    puts 'Sync the positions'
    Position.all.order(:id).find_in_batches(batch_size: 20) do |positions|
      puts "positions: #{positions.pluck(:id)}"
      pos = positions.collect do |p|
        prefix = if p.company_name.present?
                   "#{p.company_name};#{p.functional_category}"
                 else
                   p.functional_category
                 end
        position_no = p.id
        position_name = "#{prefix};#{p.name}"
        puts "Yxt.update_position_info(#{position_no}, #{position_name})"
        res = Yxt.update_position_info(position_no, position_name)
        puts res.body.to_s
        {
          pNames: position_name,
          pNo: position_no
        }
      end
      puts "Yxt.insert_positions(pos): #{pos}"
      res = Yxt.insert_positions(pos)
      puts res.body.to_s
    end
  end

  desc 'Sync job level to YXT'
  task sync_job_levels: :environment do
    puts 'Sync job levels'
    job_levels = Profile.where.not(job_level: nil).select(:job_level).distinct.pluck(:job_level).collect { |j| { id: j, name: j } }
    res = Yxt.upd_grade(job_levels)
    puts res.body.to_s
  end

  desc 'Sync the users to YXT'
  task sync_users: :environment do
    puts 'Sync the users'
    User.where(locked_at: nil).order(:id).find_in_batches(batch_size: 100) do |users|
      puts "users: #{users.pluck(:id)}"
      users = users.collect do |u|
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.position_users.last&.position if main_position.nil?

        {
          id: u.id,
          userName: u.username,
          password: '',
          cnName: u&.profile&.chinese_name || u.username,
          userNo: u&.profile&.clerk_code,
          sex: u.profile.present? ? (u.profile.gender ? '男' : '女') : '',
          mobile: u&.profile&.phone,
          isMobileValidated: 1,
          mail: u.email,
          orgOuCode: u.departments.last&.id,
          postionNo: main_position&.id,
          birthday: u&.profile&.birthdate,
          entrytime: u&.profile&.entry_company_date,
          spare1: main_position&.functional_category,
          spare2: u&.profile&.job_level,
          gradeName: u&.profile&.job_level
        }
      end
      res = Yxt.sync_users(users)
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
      {
        id: d.id,
        parentId: d.managed_by_department_id,
        ouName: d.name,
        orderIndex: d.dept_code.gsub(/[^0-9,.]/, ""),
        description: d.dept_code,
        users: []
      }
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
