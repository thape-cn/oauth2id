class DoorkeeperApplication < Doorkeeper::Application
  has_many :user_allowed_applications, foreign_key: :oauth_application_id
  has_many :department_allowed_applications, foreign_key: :oauth_application_id
  has_many :position_allowed_applications, foreign_key: :oauth_application_id

  def user_allowed_access?(user_id)
    user_allowed_applications.exists?(enable: true, user_id: user_id)
  end

  def department_allowed_access?(department_ids)
    department_allowed_applications.exists?(department_id: department_ids)
  end

  def position_allowed_access?(position_ids)
    position_allowed_applications.exists?(position_id: position_ids)
  end
end
