class DoorkeeperController < ApplicationController
  before_action :doorkeeper_authorize!, only: :me
  before_action -> { doorkeeper_authorize! :public }, only: :profiles
  content_security_policy_report_only only: :options_authorize
  skip_before_action :verify_authenticity_token, only: :options_authorize

  def me
    resource_owner = current_resource_owner
    profile = resource_owner.profile

    departments = resource_owner.departments.collect do |department|
      { id: department.id, name: department.name }
    end
    positions = resource_owner.positions.collect do |position|
      { id: position.id, name: position.name, functional_category: position.functional_category }
    end
    main_position = resource_owner.position_users.find_by(main_position: true)&.position
    main_position = resource_owner.position_users.last&.position if main_position.nil?
    main_position = if main_position.present?
      { id: main_position.id, name: main_position.name, functional_category: main_position.functional_category }
    end
    entry_company_date = profile&.entry_company_date || Date.today
    me_hash = {
      sub: resource_owner.id,
      name: resource_owner.username,
      chinese_name: profile&.chinese_name,
      clerk_code: profile&.clerk_code,
      email: resource_owner.email,
      desk_phone: resource_owner.desk_phone,
      job_level: profile&.job_level,
      gender: profile&.gender ? 'Male' : 'Female',
      departments: departments,
      positions: positions,
      main_position: main_position,
      entry_company_date: entry_company_date
    }
    render json: me_hash
  end

  def profiles
    render json: { info: 'more information here' }
  end

  def options_authorize
    head :no_content
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
