class SystemInfoPolicy < ApplicationPolicy
  def show?
    user&.admin?
  end
end
