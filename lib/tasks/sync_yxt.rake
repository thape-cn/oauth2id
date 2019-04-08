namespace :sync_yxt do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_departments_with_no_parent, :sync_1st_level_departments, :sync_2nd_level_departments, :sync_3rd_level_departments]

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

  desc 'Sync the position to YXT'
  task sync_positions: :environment do
    puts 'Sync the positions'
    positions = Position.all.collect do |p|
      {
        pNames: "#{p.functional_category};#{p.name}",
        pNo: p.id
      }
    end
    res = Yxt.sync_position(positions)
    puts res.body.to_s
  end

  desc 'Sync the users to YXT'
  task sync_users: :environment do
    puts 'Sync the users'
    User.all.find_in_batches(batch_size: 200) do |users|
      puts "users: #{users.pluck(:id)}"
      users = users.collect do |u|
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.positions.first if main_position.nil?

        {
          ID: u.id,
          UserName: u.username,
          Password: '',
          CnName: u&.profile&.chinese_name,
          Sex: u.profile.present? ? (u.profile.gender ? '男' : '女') : '',
          Mobile: '',
          Mail: u.email,
          OrgOuCode: u.departments.first&.id,
          PostionNo: main_position&.id,
          Birthday: '',
          Entrytime: ''
        }
      end
      res = Yxt.sync_users(users)
      puts res.body.to_s
    end
  end

  def yxt_department(managed_by_department_ids)
    Department.where(managed_by_department_id: managed_by_department_ids).collect do |d|
      {
        ID: d.id,
        ParentID: d.managed_by_department_id,
        OuName: d.name,
        Description: d.dept_code,
        Users: []
      }
    end
  end
end
