class EmployeesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User

    users = policy_scope(User)
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params, users: users) }
    end
  end
end
