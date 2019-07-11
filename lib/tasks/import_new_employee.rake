namespace :import_new_employee do
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
end
