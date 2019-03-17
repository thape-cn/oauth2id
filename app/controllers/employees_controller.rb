class EmployeesController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params) }
    end
  end
end
