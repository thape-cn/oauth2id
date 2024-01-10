class PositionPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def edit?
    user&.admin?
  end

  def update?
    edit?
  end
end
