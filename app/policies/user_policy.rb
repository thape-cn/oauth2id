class UserPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user&.admin?
  end

  def system_role_name
    return unless user.present?

    if user&.admin?
      ActionController::Base.helpers.content_tag :p, I18n.t('ui.system_administrator'), class: 'app-sidebar__user-designation'
    end
  end
end
