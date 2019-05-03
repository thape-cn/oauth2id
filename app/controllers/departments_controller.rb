class DepartmentsController < ApplicationController
  before_action :authenticate_user!

  def data
    render json: [{name: 'Test1', id: 1, load_on_demand: true},{name: 'Test2', id: 2, load_on_demand: true}]
  end
end
