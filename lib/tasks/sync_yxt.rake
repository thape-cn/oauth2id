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
            .where.not(functional_category_id: nil)
            .where.not(b_postname: [nil, ''])
            .select(:b_postcode, :b_postname, :post_level, :functional_category_id)
            .distinct
            .order(:b_postcode, :b_postname, :post_level, :functional_category_id)
            .pluck(:b_postcode, :b_postname, :post_level, :functional_category_id)
            .each do |b_postcode, b_postname, post_level, functional_category_id|
      pos = {
        name: b_postname,
        thirdId: b_postcode,
        catalogThirdId: functional_category_id,
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
    User.where(id: 4431).order(:id).find_each do |u|
      main_position = u.position_users.find_by(main_position: true)&.position
      main_position = u.position_users.last&.position if main_position.nil?

      dept = if main_position.present? && main_position.department.present?
               main_position.department
             else
               u.departments.first
             end
      position_company_names = if main_position.nil?
        nil
      else
        ([main_position.company_name] + u.positions.collect(&:company_name)).compact.uniq
      end
      yxt_disabled = u.locked_at.present? ||
                     u.positions.blank? ||
                     main_position.name.start_with?('实习生') ||
                     main_position.name.end_with?('实习生') ||
                     (position_company_names & yxt_excluded_company_names).any?

      yxt_user = {
        thirdUserId: u.id,
        username: u.yxt_user_name,
        fullname: u&.profile&.chinese_name || u.username,
        userNo: u&.profile&.clerk_code,
        email: u.email,
        mobile: u&.profile&.phone,
        birthday: yxt_date(u&.profile&.birthdate),
        deptThirdId: dept&.id.to_s,
        parttimeDeptThirdIds: (u.departments.collect { |d| d.id.to_s } - [dept&.id.to_s]).join(','),
        positionThirdId: main_position&.b_postcode,
        parttimePositionThirdIds: (u.positions.collect { |p| p.b_postcode } - [main_position&.b_postcode]).join(','),
        gradeThirdId: main_position&.post_level,
        hireDate: yxt_date(u&.profile&.entry_company_date),
        gender: (u&.profile.blank? ? '0' : (u&.profile.gender ? '1' : '2')),
        status: (yxt_disabled ? 0 : 1),
        distinctType: 1, # 用户唯一标识判断 thirdUserId
      }

      puts "Yxt.users_recoversync(yxt_user): #{yxt_user}"
      res = Yxt.users_recoversync(yxt_user)
      yxt_response = print_yxt_response(res, context: 'Yxt.users_recoversync')
      yxt_user_id = sync_yxt_user_id(u, yxt_response)
      sync_yxt_wecom_auth_bund(u, yxt_user_id) if yxt_response.present?
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

  def yxt_excluded_company_names
    [
      'EID GROUP LIMITED',
      '上海天华易衡光伏科技有限公司',
      '上海天华易衡节能科技有限公司',
      '上海天华迈卓管理咨询有限公司',
      '上海易湃富得环保科技有限公司',
      '上海易湃环境工程技术有限公司',
      '上海环境研究中心有限公司',
      '上海虹核工程审图有限公司',
      '天华测试组织',
      '天华迈卓（上海）资产管理有限公司',
      '山东易衡节能科技有限公司',
      '广德易衡生物能源有限公司',
      '昆明天华建筑设计有限公司',
      '武汉天华嘉易建筑设计有限公司',
      '武汉天华易筑室内设计有限公司',
      '深圳天华易筑室内设计有限公司',
      '福州天华建筑设计有限公司',
      '舟山易衡光伏科技有限公司',
    ]
  end

  def print_yxt_response(response, context: nil)
    unless response.respond_to?(:body)
      puts "#{context} error response: #{response.inspect}"
      return
    end

    body = response.body.to_s
    payload = yxt_response_payload(body)
    return payload if yxt_response_success?(payload)

    puts body
  end

  def sync_yxt_user_id(user, yxt_response)
    yxt_user_id = yxt_response&.dig('data', 'id')
    return user.profile&.yxt_user_id if yxt_user_id.blank?

    profile = user.profile || user.build_profile
    profile.update!(yxt_user_id: yxt_user_id)
    profile.yxt_user_id
  end

  def sync_yxt_wecom_auth_bund(user, yxt_user_id)
    wecom_id = user.profile&.wecom_id
    if wecom_id.blank? || yxt_user_id.blank?
      puts "Skip YXT WeCom auth bund: user_id=#{user.id}, " \
           "wecom_id=#{wecom_id.inspect}, yxt_user_id=#{yxt_user_id.inspect}"
      return
    end

    encrypt_payload = {
      userIds: [wecom_id],
      type: 0,
      agentId: yxt_wechat_agent_id,
      corpId: yxt_wechat_corp_id
    }
    puts "Yxt.openuser_userid_encrypt(encrypt_payload): #{encrypt_payload}"
    encrypt_res = Yxt.openuser_userid_encrypt(encrypt_payload)
    encrypt_response = print_yxt_response(encrypt_res, context: 'Yxt.openuser_userid_encrypt')
    open_id = yxt_encrypt_open_id(encrypt_response, wecom_id)

    if open_id.blank?
      puts "Skip YXT WeCom auth bund: encrypted openId is blank for user_id=#{user.id}, wecom_id=#{wecom_id}"
      return
    end

    bund_payload = {
      agentId: yxt_wechat_agent_id,
      openId: open_id,
      type: 1,
      userId: yxt_user_id
    }
    puts "Yxt.auth_bund(bund_payload): #{bund_payload}"
    bund_res = Yxt.auth_bund(bund_payload)
    print_yxt_response(bund_res, context: 'Yxt.auth_bund')
  end

  def yxt_response_payload(body)
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end

  def yxt_response_success?(payload)
    return false unless payload.is_a?(Hash)

    payload['msg'].to_s.casecmp('success').zero? && payload['subMsg'].to_s.casecmp('success').zero?
  end

  def yxt_encrypt_open_id(response, wecom_id)
    yxt_open_id_from_data(response&.dig('data'), wecom_id)
  end

  def yxt_open_id_from_data(data, wecom_id)
    case data
    when Hash
      yxt_open_id_from_hash(data, wecom_id)
    when Array
      yxt_open_id_from_array(data, wecom_id)
    when String
      data
    end
  end

  def yxt_open_id_from_hash(data, wecom_id)
    open_id = data['openId'] || data[:openId] || data['openid'] || data[:openid] ||
              data['encryptedUserId'] || data[:encryptedUserId] || data['encryptUserId'] || data[:encryptUserId]
    return open_id if open_id.present?

    mapped_value = data[wecom_id] || data[wecom_id.to_sym]
    return yxt_open_id_from_data(mapped_value, wecom_id) if mapped_value.present?

    list = data['userIds'] || data[:userIds] || data['users'] || data[:users] || data['list'] || data[:list]
    yxt_open_id_from_data(list, wecom_id)
  end

  def yxt_open_id_from_array(data, wecom_id)
    matched_item = data.find do |item|
      item.is_a?(Hash) && [
        item['userId'], item[:userId], item['userid'], item[:userid], item['wecomId'], item[:wecomId]
      ].compact.map(&:to_s).include?(wecom_id.to_s)
    end
    return yxt_open_id_from_data(matched_item, wecom_id) if matched_item.present?

    return data.first if data.one? && data.first.is_a?(String)
  end

  def yxt_wechat_agent_id
    Rails.application.credentials.wechat_agentid!.to_s
  end

  def yxt_wechat_corp_id
    Rails.application.credentials.wechat_corpid!.to_s
  end

  def yxt_date(value)
    return if value.blank?

    value.strftime("%F")
  end
end
