require 'csv'

class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_and_authorized, except: %i[index report]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User

    dept = Department.find_by(id: params[:dept_id])
    users = if dept.present?
      policy_scope(User).joins(:department_users)
        .where(department_users: {department_id: dept.all_managed_department_ids}).references(:department_users)
    else
      policy_scope(User)
    end.left_joins(:profile).references(:profile)
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params, users: users, view_context: view_context) }
    end
  end

  def report
    authorize User

    respond_to do |format|
      format.csv do
        render_csv_header :user_report.to_s
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'User Name', 'Chinese Name', 'Clerk Code', 'eMail', 'Title', 'Department', 'Position']
          policy_scope(User).where(locked_at: nil).order(id: :asc).find_each do |user|
            values = []
            values << user.id
            values << user.username
            values << user.profile.chinese_name
            values << user.profile.clerk_code
            values << user.email
            values << user.profile&.title
            values << user.departments.pluck(:name).join(';')
            values << user.positions.pluck(:name).join(';')
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF" << csv_res
      end
    end
  end

  def show
  end

  def sign_in_histories
    render :show
  end

  def edit
    @user.profile || @user.build_profile
    need_append_application_ids = DoorkeeperApplication.pluck(:id) - @user.user_allowed_applications.pluck(:oauth_application_id)
    need_append_application_ids.each do |application_id|
      @user.user_allowed_applications.build(oauth_application_id: application_id, enable: false)
    end
  end

  def update
    @user.skip_confirmation_notification!
    if @user.update(user_params) && @user.confirm
      redirect_to employees_path, notice: I18n.t('ui.update_success')
    else
      render 'edit'
    end
  end

  private

  def set_user_and_authorized
    @user = User.find(params[:id])
    authorize @user
  end

  def user_params
    params.require(:user).permit(:email, :username, profile_attributes: [:id, :title], user_allowed_applications_attributes: [:id, :enable, :oauth_application_id])
  end
end
