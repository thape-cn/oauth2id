namespace :sync_nc_uap do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_orgs, :sync_departments, :sync_positions, :sync_users, :clean_empty_department]

  desc 'Sync orgs with NC UAP'
  task sync_orgs: :environment do
    puts 'Upserts the orgs'
    NcUap.upserts_orgs_as_departments
  end

  desc 'Sync department with NC UAP'
  task sync_departments: :environment do
    puts 'Upserts the departments'
    NcUap.upserts_departments
    puts 'Sync managed by departments with fatherorg'
    NcUap.sync_managed_by_department_with_fatherorg
  end

  desc 'Sync positions with NC UAP (NC called om_post)'
  task sync_positions: :environment do
    puts 'Upserts the positions'
    NcUap.upserts_positions
  end

  desc 'Sync users with NC UAP'
  task sync_users: :environment do
    puts 'Upserts the users'
    NcUap.upserts_users
  end

  desc 'Clean empty department'
  task clean_empty_department: :environment do
    puts 'Clean empty department'
    Department.all.pluck(:id).each do |department_id|
      department = Department.find department_id
      department.destroy if department.users.count == 0 && department.managed_departments.count == 0
    end
  end
end
