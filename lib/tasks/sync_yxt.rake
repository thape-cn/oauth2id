namespace :sync_yxt do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_departments_with_no_parent, :sync_1st_level_departments,
    :sync_2nd_level_departments, :sync_3rd_level_departments, :sync_4nd_level_departments,
    :sync_5nd_level_departments, :sync_positions, :sync_users, :disable_users]

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
    Position.all.order(:id).find_in_batches(batch_size: 1000) do |positions|
      puts "positions: #{positions.pluck(:id)}"
      pos = positions.collect do |p|
        prefix = if p.company_name.present?
          "#{p.company_name};#{p.functional_category}"
        else
          p.functional_category
        end
        {
          pNames: "#{prefix};#{p.name}",
          pNo: p.id
        }
      end
      res = Yxt.sync_position(pos)
      puts res.body.to_s
    end
  end

  desc 'Sync the users to YXT'
  task sync_users: :environment do
    puts 'Sync the users'
    User.where(locked_at: nil).order(:id).find_in_batches(batch_size: 100) do |users|
      puts "users: #{users.pluck(:id)}"
      users = users.collect do |u|
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.positions.last if main_position.nil?

        {
          ID: u.id,
          UserName: u.username,
          Password: '',
          CnName: u&.profile&.chinese_name,
          userno: u&.profile&.clerk_code,
          Sex: u.profile.present? ? (u.profile.gender ? '男' : '女') : '',
          Mobile: u&.profile&.phone,
          Mail: u.email,
          OrgOuCode: u.departments.last&.id,
          PostionNo: main_position&.id,
          Birthday: u&.profile&.birthdate,
          Entrytime: u&.profile&.entry_company_date,
          Spare1: main_position&.functional_category,
          Spare2: u&.profile&.job_level
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
      userNames = users.pluck(:username)
      res = Yxt.disable_users(userNames)
      puts res.body.to_s
    end
  end

  def yxt_department(managed_by_department_ids)
    Department.where(managed_by_department_id: managed_by_department_ids).collect do |d|
      {
        ID: d.id,
        ParentID: d.managed_by_department_id,
        OuName: d.name,
        OrderIndex: d.dept_code.gsub(/[^0-9,.]/, ""),
        Description: d.dept_code,
        Users: []
      }
    end
  end

  desc 'Disable all non-Shanghai users'
  task disable_non_shanghai_users: :environment do
    all_shanghai_department_ids = Department.find(644).all_managed_department_ids
    exclude_department_1 = Department.find(36).all_managed_department_ids
    exclude_department_2 = Department.find(191).all_managed_department_ids
    exclude_department_3 = Department.find(467).all_managed_department_ids
    enable_department_ids = all_shanghai_department_ids - exclude_department_1 - exclude_department_2 - exclude_department_3
    disable_department_ids = Department.pluck(:id) - enable_department_ids
    puts "Disable department ids: #{disable_department_ids}"
    User.joins(:department_users).where(department_users: { department_id: disable_department_ids }, locked_at: nil).order(:id).find_in_batches(batch_size: 100) do |users|
      userNames = users.pluck(:username)
      res = Yxt.disable_users(userNames)
      puts res.body.to_s
    end
  end
end
