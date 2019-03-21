class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_and_authorized, except: :index
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User

    users = policy_scope(User)
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params, users: users, view_context: view_context) }
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
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
    params.require(:user).permit(profile_attributes: [:id, :title])
  end
end
