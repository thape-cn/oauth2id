class DepartmentPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def edit?
    user&.admin?
  end

  def update?
    edit?
  end
end
