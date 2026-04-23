require 'json'

namespace :sync_yxt do
  desc "Sync department, positions and users data with NC UAP"
  task :all => [:sync_departments_with_no_parent, :sync_1st_level_departments,
    :sync_2nd_level_departments, :sync_3rd_level_departments, :sync_4th_level_departments,
    :sync_5th_level_departments, :sync_6th_level_departments, :sync_position_catalog, :sync_position_grade,
    :sync_yxt_positions, :sync_users]

  desc 'Sync department which no parent departments'
  task sync_departments_with_no_parent: :environment do
    puts 'Sync the no parent departments'
    root_departments = yxt_department(nil)
    sync_yxt_departments(root_departments)
  end

  desc 'Sync the 1st level departments'
  task sync_1st_level_departments: :environment do
    puts 'Sync the 1st level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_departments = yxt_department(root_department_ids)
    sync_yxt_departments(first_level_departments)
  end

  desc 'Sync the 2nd level departments'
  task sync_2nd_level_departments: :environment do
    puts 'Sync the 2nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_departments = yxt_department(first_level_department_ids)
    sync_yxt_departments(second_level_departments)
  end

  desc 'Sync the 3rd level departments'
  task sync_3rd_level_departments: :environment do
    puts 'Sync the 3rd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_departments = yxt_department(second_level_department_ids)
    sync_yxt_departments(third_level_departments)
  end

  desc 'Sync the 4nd level departments'
  task sync_4th_level_departments: :environment do
    puts 'Sync the 4nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_departments = yxt_department(third_level_department_ids)
    sync_yxt_departments(fourth_level_departments)
  end

  desc 'Sync the 5nd level departments'
  task sync_5th_level_departments: :environment do
    puts 'Sync the 5nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_department_ids = Department.where(managed_by_department_id: third_level_department_ids).pluck(:id)
    fifth_level_departments = yxt_department(fourth_level_department_ids)
    sync_yxt_departments(fifth_level_departments)
  end

  desc 'Sync the 6nd level departments'
  task sync_6th_level_departments: :environment do
    puts 'Sync the 6nd level departments'
    root_department_ids = Department.where(managed_by_department_id: nil).pluck(:id)
    first_level_department_ids = Department.where(managed_by_department_id: root_department_ids).pluck(:id)
    second_level_department_ids = Department.where(managed_by_department_id: first_level_department_ids).pluck(:id)
    third_level_department_ids = Department.where(managed_by_department_id: second_level_department_ids).pluck(:id)
    fourth_level_department_ids = Department.where(managed_by_department_id: third_level_department_ids).pluck(:id)
    fifth_level_department_ids = Department.where(managed_by_department_id: fourth_level_department_ids).pluck(:id)
    sixth_level_departments = yxt_department(fifth_level_department_ids)
    sync_yxt_departments(sixth_level_departments)
  end

  desc 'Sync the position_catalog to YXT'
  task sync_position_catalog: :environment do
    puts 'Sync the yxt_position_catalogs'
    Position.where.not(functional_category_id: nil)
            .where.not(functional_category: [nil, ''])
            .select(:functional_category_id, :functional_category)
            .distinct
            .order(:functional_category_id, :functional_category)
            .pluck(:functional_category_id, :functional_category)
            .each do |functional_category_id, functional_category|
      puts "position_grade: #{functional_category_id} - #{functional_category}"
      pos = {
        name: functional_category,
        thirdId: functional_category_id
      }
      puts "Yxt.positioncatalogs_sync(pos): #{pos}"
      res = Yxt.positioncatalogs_sync(pos)
      print_yxt_response(res, context: 'Yxt.positioncatalogs_sync')
    end
  end

  desc 'Sync the position_grade to YXT'
  task sync_position_grade: :environment do
    puts 'Sync the yxt_position_grade'
    Position.where.not(b_postcode: nil)
            .where.not(b_postname: [nil, ''])
            .select(:post_level)
            .distinct
            .order(:post_level)
            .pluck(:post_level)
            .each do |post_level|
      pos = {
        name: post_level,
        thirdId: post_level
      }
      puts "Yxt.positiongrades_sync(pos): #{pos}"
      res = Yxt.positiongrades_sync(pos)
      print_yxt_response(res, context: 'Yxt.positiongrades_sync')
    end
  end

  desc 'Sync the position to YXT'
  task sync_yxt_positions: :environment do
    puts 'Sync the yxt_positions'
    Position.where.not(b_postcode: nil)
            .where.not(b_postname: [nil, ''])
            .select(:b_postcode, :b_postname, :post_level)
            .distinct
            .order(:b_postcode, :b_postname, :post_level)
            .pluck(:b_postcode, :b_postname, :post_level)
            .each do |b_postcode, b_postname, post_level|
      pos = {
        name: b_postname,
        thirdId: b_postcode,
        catalogThirdId: p.functional_category_id,
        gradeThirdId: post_level,
      }
      puts "Yxt.positions_sync(pos): #{pos}"
      res = Yxt.positions_sync(pos)
      print_yxt_response(res, context: 'Yxt.positions_sync')
    end
  end

  desc 'Sync the users to YXT'
  task sync_users: :environment do
    puts 'Sync the users'
    User.order(:id).find_each do |u|
      main_position = u.position_users.find_by(main_position: true)&.position
      main_position = u.position_users.last&.position if main_position.nil?

      dept = if main_position.present? && main_position.department.present?
               main_position.department
             else
               u.departments.first
             end
      next if dept.blank?
      next if main_position.blank?

      yxt_user = {
        thirdUserId: u.id,
        username: u.yxt_user_name,
        fullname: u&.profile&.chinese_name || u.username,
        userNo: u&.profile&.clerk_code,
        email: u.email,
        mobile: u&.profile&.phone,
        birthday: yxt_date(u&.profile&.birthdate),
        deptThirdId: dept.id.to_s,
        parttimeDeptThirdIds: (u.departments.collect { |d| d.id.to_s } - [dept.id.to_s]).join(','),
        positionThirdId: main_position.id.to_s,
        parttimePositionThirdIds: (u.positions.collect { |p| p.id.to_s } - [main_position.id.to_s]).join(','),
        gradeThirdId: main_position.b_postcode,
        hireDate: yxt_date(u&.profile&.entry_company_date),
        gender: (u&.profile.blank? ? '0' : (u&.profile.gender ? '1' : '2')),
        status: (u.locked_at.present? ? 0 : 1),
        distinctType: 1, # 用户唯一标识判断 thirdUserId
      }

      puts "Yxt.users_recoversync(yxt_user): #{yxt_user}"
      res = Yxt.users_recoversync(yxt_user)
      print_yxt_response(res, context: 'Yxt.users_recoversync')
    end
  end

  def yxt_department(managed_by_department_ids)
    Department.where(managed_by_department_id: managed_by_department_ids).collect do |d|
      dept_hash = {
        thirdId: d.id.to_s,
        name: d.name,
        description: d.company_name,
        code: d.dept_code
      }

      dept_hash[:parentThirdId] = d.managed_by_department_id.to_s if d.managed_by_department_id.present?

      order_index = d.dept_code.to_s.gsub(/[^0-9]/, '')
      dept_hash[:orderIndex] = order_index.to_i if order_index.present?
      dept_hash
    end
  end

  def sync_yxt_departments(departments)
    departments.each do |department|
      res = Yxt.depts_sync(department)
      print_yxt_response(res, context: 'Yxt.depts_sync')
    end
  end

  def print_yxt_response(response, context: nil)
    unless response.respond_to?(:body)
      puts "#{context} error response: #{response.inspect}"
      return
    end

    body = response.body.to_s
    return if yxt_response_success?(body)

    puts body
  end

  def yxt_response_success?(body)
    payload = JSON.parse(body)
    return false unless payload.is_a?(Hash)

    payload['msg'].to_s.casecmp('success').zero? && payload['subMsg'].to_s.casecmp('success').zero?
  rescue JSON::ParserError
    false
  end

  def yxt_date(value)
    return if value.blank?

    value.strftime("%F")
  end
end
