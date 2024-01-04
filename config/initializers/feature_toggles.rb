module FeatureToggles
  def self.allow_user_signup?
    ENV.fetch('ALLOW_USER_SIGNUP', 'true') == 'true'
  end

  def self.allow_admin_grant_admin?
    ENV.fetch('ALLOW_ADMIN_GRANT_ADMIN', 'true') == 'true'
  end
end
