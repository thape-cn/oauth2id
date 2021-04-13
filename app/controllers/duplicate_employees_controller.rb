class DuplicateEmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profiles, only: %i[index report]

  def index
  end

  def report
    respond_to do |format|
      format.csv do
        render_csv_header :duplicate_employees_report.to_s
        csv_res = CSV.generate do |csv|
          csv << ['chinese_name', 'clerk_code', 'account_counts']
          @profiles.each_with_index do |p, index|
            du = Profile.includes(:user).where(chinese_name: p.chinese_name, clerk_code: p.clerk_code)
            next if du.collect(&:user).all? { |u| u&.locked_at.present? }
            next if du.collect(&:user).one? { |u| u&.locked_at.nil? }

            values = []
            values << p.chinese_name
            values << p.clerk_code
            values << du.collect { |d| d.user.username }.join(';')
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
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

  private

    def set_profiles
      @profiles = policy_scope(Profile)
        .select('chinese_name, clerk_code, COUNT(user_id) account_counts')
        .group(:chinese_name, :clerk_code)
        .having('count(user_id) > 1')
        .where.not(clerk_code: nil)
        .order('account_counts DESC, clerk_code DESC')
    end
end
