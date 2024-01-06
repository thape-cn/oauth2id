class DoorkeeperApplication < Doorkeeper::Application
  has_many :user_allowed_applications, foreign_key: :oauth_application_id
  has_many :department_allowed_applications, foreign_key: :oauth_application_id
  has_many :position_allowed_applications, foreign_key: :oauth_application_id

  def user_allowed_access?(user_id)
    user_allowed_applications.exists?(enable: true, user_id: user_id)
  end
end
