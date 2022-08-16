require 'roo'

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

  desc 'Import wecom_id from Tianhua2020 DB'
  task import_wecom_id_from_db: :environment do
    Bill::Tianhua2020.all.each do |t|
      p = Profile.find_by(clerk_code: format('%06d', t.clerkcode))
      next if p.nil?

      p.update_columns(wecom_id: t.wecom_id)
    end
  end

  desc 'Import wecom_id from Excel file'
  task :import_wecom_id_from_excel, [:file_path] => [:environment] do |task, args|
    excel_file_path = args[:file_path]
    return unless excel_file_path.present?

    xlsx = Roo::Excelx.new(excel_file_path)
    xlsx.each_row_streaming(offset: 1) do |row|
      微信账号 = row[0]&.value&.to_s&.strip
      邮箱 = row[1]&.value&.to_s&.strip

      u = User.find_by(email: 邮箱)
      next if u.nil?

      puts "Update: #{邮箱} with #{微信账号}"
      profile = u.profile || u.build_profile
      profile.update(wecom_id: 微信账号)
    end
  end

  desc 'Export two CSV for cybros import'
  task export_cybros_all: :environment do
    all_position = 'all_positions.csv'
    all_employee = 'all_employees.csv'
    Export.position_csv(all_position)
    Export.user_for_cybros(all_employee)
    Net::SFTP.start('thape_vendor', 'cybros_bi') do |sftp|
      sftp.upload!(all_position, all_position)
      sftp.upload!(all_employee, all_employee)
    end
  end

  desc 'Export positions CSV'
  task :export_position_csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    Export.position_csv(csv_file_path)
  end

  desc 'Export CSV the user list for Cybros'
  task :export_for_cybros, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    Export.user_for_cybros(csv_file_path)
  end
end
