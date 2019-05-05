class DepartmentsController < ApplicationController
  before_action :authenticate_user!

  def data
    managed_by_department_id = params[:node]
    departments = Department.where(managed_by_department_id: managed_by_department_id).collect do |d|
      { name: d.name, id: d.id, load_on_demand: d.managed_departments.count > 0 }
    end
    render json: departments
  end
end
