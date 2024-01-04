class DepartmentsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_policy_scoped

  def index
    authorize Department

    departments = policy_scope(Department)

    respond_to do |format|
      format.html
      format.json { render json: DepartmentDatatable.new(params, departments: departments, view_context: view_context) }
    end
  end

  def data
    managed_by_department_id = params[:node]
    departments = policy_scope(Department).where(managed_by_department_id: managed_by_department_id).collect do |d|
      { name: d.name, id: d.id, load_on_demand: d.managed_departments.count.positive? }
    end
    render json: departments
  end
end
