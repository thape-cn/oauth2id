class EmployeesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    users = policy_scope(User)
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params, users: users) }
    end
  end
end
