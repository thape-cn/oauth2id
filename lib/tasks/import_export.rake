namespace :import_export do
  desc "Create new users from CSV"
  task :import_from_csv, [:csv_file_path] => [:environment] do |task, args|
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

  desc "Export CSV the user list for Cybros"
  task :export_for_cybros, [:csv_file_path] => [:environment] do |task, args|
    csv_file_path = args[:csv_file_path]
    CSV.open(csv_file_path, "w") do |csv|
      csv << ["email", "position_title", "clerk_code", "chinese_name", "combine_departments"]
      User.order(id: :asc).find_each do |u|
        values = []
        values << u.email
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.positions.last if main_position.nil?
        values << main_position&.name
        values << u.profile&.clerk_code
        values << u.profile&.chinese_name
        combine_deparments = u.departments.collect do |department|
          "#{department.name}@#{department.company_name}"
        end.join(';')
        values << combine_deparments
        csv << values
      end
    end
  end
end
