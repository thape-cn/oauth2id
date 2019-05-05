class DepartmentPolicy < ApplicationPolicy
  def show?
    user&.admin?
  end
end
