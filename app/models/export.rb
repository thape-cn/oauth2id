class Export
  def self.position_csv(csv_file_path)
    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[name functional_category dept_code b_postcode b_postname nc_pk_post job_type_code post_level]
      Position.order(id: :asc).find_each do |p|
        values = []
        values << p.name
        values << p.functional_category
        dept_code = Department.find_by(id: p.department_id)&.dept_code
        values << dept_code

        values << p.b_postcode
        values << p.b_postname
        values << p.nc_pk_post
        values << p.job_type_code
        values << p.post_level
        csv << values
      end
    end
  end

  def self.user_for_cybros(csv_file_path)
    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[email position_title nc_pk_post gender clerk_code pre_sso_id chinese_name job_level major_code major_name entry_company_date pre_sso_id wecom_id locked_at mobile desk_phone combine_departments combine_positions]
      User.order(id: :asc).find_each do |u|
        values = []
        values << u.email
        main_position = u.position_users.find_by(main_position: true)&.position
        main_position = u.position_users.last&.position if main_position.nil?
        values << main_position&.name
        values << main_position&.nc_pk_post
        values << u.profile&.gender
        values << u.profile&.clerk_code
        values << u.profile&.pre_sso_id
        values << u.profile&.chinese_name
        values << u.profile&.job_level
        values << u.profile&.major_code
        values << u.profile&.major_name
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
          "#{pu.position.id}@#{pu.position.name}@#{pu.position.functional_category}@#{pu.position.department&.dept_code}@#{pu.position.department&.name}@#{pu.position.department&.company_code}@#{pu.position.nc_pk_post}@#{pu.position.b_postcode}@#{pu.position.b_postname}@#{pu.position.department&.dept_category}@#{pu.position.department&.company_name}@#{pu.main_position}"
        end.join(';')
        values << combine_positions
        csv << values
      end
    end
  end
end
