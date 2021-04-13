class DuplicateEmployeesController < ApplicationController
  before_action :authenticate_user!

  def index
    @profiles = policy_scope(Profile)
      .select('chinese_name, clerk_code, COUNT(user_id) account_counts')
      .group(:chinese_name, :clerk_code)
      .having('count(user_id) > 1')
      .where.not(clerk_code: nil)
      .order('account_counts DESC, clerk_code DESC')
  end

  def report
  end

  def show
    @clerk_code = params[:id]
    @duplicate_users = User.joins(:profile).where(profile: { clerk_code: @clerk_code })
  end

  def update
    main_user = User.find params[:main_user_id]
    to_remove_users = User.joins(:profile)
      .where(profile: { clerk_code: main_user.profile.clerk_code })
      .where.not(id: main_user.id)

    to_remove_users.each do |merge_user|
      merge_user.department_users.pluck(:department_id).each do |department_id|
        main_user.department_users.find_or_create_by(department_id: department_id)
      end
      merge_user.position_users.pluck(:position_id).each do |position_id|
        main_user.position_users.find_or_create_by(position_id: position_id)
      end
      UserSignInHistory.where(user_id: merge_user.id).update_all(user_id: main_user.id)
      merge_user.user_allowed_applications.pluck(:oauth_application_id).each do |oauth_application_id|
        main_user.user_allowed_applications.find_or_create_by(oauth_application_id: oauth_application_id)
      end
      merge_user.destroy!
    end

    redirect_to duplicate_employee_path(id: main_user.profile.clerk_code), notice: I18n.t('ui.merge_success')
  end
end
