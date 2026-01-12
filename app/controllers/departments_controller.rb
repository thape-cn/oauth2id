class DepartmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_department_and_authorized, except: %i[index data]
  after_action :verify_policy_scoped, only: %i[index data]

  def index
    authorize Department

    departments = policy_scope(Department)

    respond_to do |format|
      format.html
      format.json { render json: DepartmentDatatable.new(params, departments: departments, view_context: view_context) }
    end
  end

  def edit
  end

  def update
    @department.update(department_params)
  end

  def data
    managed_by_department_id = params[:node]
    departments = policy_scope(Department).where(managed_by_department_id: managed_by_department_id)
    managed_counts = Department.where(managed_by_department_id: departments.select(:id))
                               .group(:managed_by_department_id)
                               .count

    render json: departments.map { |d|
      { name: d.name, id: d.id, load_on_demand: managed_counts[d.id].to_i.positive? }
    }
  end

  private

  def set_department_and_authorized
    @department = Department.find(params[:id])
    authorize @department
  end

  def department_params
    params.require(:department).permit(:name, allowed_application_ids: [])
  end
end
