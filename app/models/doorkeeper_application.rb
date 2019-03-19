class DoorkeeperApplication < Doorkeeper::Application
  has_many :user_allowed_applications, foreign_key: :oauth_application_id
end
