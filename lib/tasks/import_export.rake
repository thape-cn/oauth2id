namespace :import_export do
  desc 'Create new users from CSV'
  task :import_from_csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    CSV.foreach(csv_file_path, headers: true) do |row|
      chinese_name = row['姓名']
      email = row['邮箱']
      user_name = email.split('@').first
      puts "Creating: chinese_name  #{chinese_name}, email: #{email} user_name: #{user_name}"
      user = User.find_or_create_by(username: user_name, email: email)
      user.skip_password_validation = true
      user.save
      profile = user.profile || user.build_profile
      profile.update(chinese_name: chinese_name)
    end
  end

  desc 'Import wecom_id from Tianhua2020'
  task import_wecom_id: :environment do
    Bill::Tianhua2020.all.each do |t|
      p = Profile.find_by(clerk_code: format('%06d', t.clerkcode))
      next if p.nil?

      p.update_columns(wecom_id: t.wecom_id)
    end
  end

  desc 'Export CSV the user list for Cybros'
  task :export_for_cybros, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[email position_title gender clerk_code pre_sso_id chinese_name job_level entry_company_date pre_sso_id wecom_id locked_at mobile desk_phone combine_departments combine_positions]
      User.order(id: :asc).find_each do |u|
        values = []
        values << u.email
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.position_users.last&.position if main_position.nil?
        values << main_position&.name
        values << u.profile&.gender
        values << u.profile&.clerk_code
        values << u.profile&.pre_sso_id
        values << u.profile&.chinese_name
        values << u.profile&.job_level
        values << u.profile&.entry_company_date
        values << u.profile&.pre_sso_id
        values << u.profile&.wecom_id
        values << u.locked_at&.to_date
        values << u.profile&.phone
        values << u.desk_phone
        combine_deparments = u.departments.collect do |department|
          "#{department.id}@#{department.name}@#{department.dept_code}@#{department.company_name}@#{department.company_code}@#{department.dept_category}"
        end.join(';')
        values << combine_deparments
        combine_positions = u.position_users.collect do |pu|
          "#{pu.position.id}@#{pu.position.name}@#{pu.position.functional_category}@#{pu.position.department&.dept_code}@#{pu.position.department&.name}@#{pu.position.department&.company_code}@#{pu.position.pk_poststd}@#{pu.position.b_postcode}@#{pu.position.b_postname}@#{pu.position.department&.dept_category}@#{pu.position.department&.company_name}@#{pu.main_position}@#{pu.post_level}@#{pu.job_type_code}"
        end.join(';')
        values << combine_positions
        csv << values
      end
    end
  end
end
