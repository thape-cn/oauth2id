require 'tiny_tds'

namespace :sync_nc_uap do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_orgs, :sync_departments, :sync_positions, :sync_users, :sync_old_sso_id, :link_user_to_yxt_position]

  desc 'Sync orgs with NC UAP'
  task sync_orgs: :environment do
    puts 'Upserts the orgs'
    NcUap.upserts_orgs_as_departments_all
  end

  desc 'Sync department with NC UAP'
  task sync_departments: :environment do
    puts 'Upserts the departments'
    NcUap.upserts_departments
    puts 'Sync managed by departments with fatherorg'
    NcUap.sync_managed_by_department_with_fatherorg
    NcUap.upserts_missing_orgs_as_departments
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
    NcUap.upserts_position_users
    NcUap.set_profile_job_level
    NcUap.upserts_user_majors
    puts 'Lock the leaved users'
    NcUap.enable_all_users
    NcUap.lock_leaved_users
  end

  desc 'Sync user old sso id'
  task sync_old_sso_id: :environment do
    username = Rails.application.credentials.old_sso_username!
    password = Rails.application.credentials.old_sso_password!
    host = Rails.application.credentials.old_sso_host!
    database = Rails.application.credentials.old_sso_database!
    client = TinyTds::Client.new username: username, password: password, host: host, database: database, timeout: 30
    result = client.execute('select Id,NCWorkNo from [Thape_SSO].[dbo].[v_UserInfo]')
    result.each do |row|
      clerk_code = row['NCWorkNo']
      pre_sso_id = row['Id']
      profile = Profile.find_by clerk_code: clerk_code
      if profile.present?
        profile.update(pre_sso_id: pre_sso_id)
      else
        puts "Missing clert_code: #{clerk_code} ID: #{pre_sso_id}"
      end
    end
  end

  desc 'Link user to YxtPosition'
  task link_user_to_yxt_position: :environment do
    User.all.order(:id).find_each do |user|
      next if user.position_users.blank?

      p = user.position_users.find_by(main_position: true)&.position
      p = user.position_users.last&.position if p.nil?
      prefix = p.functional_category
      position_name = "#{prefix};#{p.name}"
      yxt_position = YxtPosition.find_or_create_by!(prefix_paths: position_name, position_name: p.name)
      user.update_columns(yxt_position_id: yxt_position.id)
    end
  end
end
