class PositionPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end
end
