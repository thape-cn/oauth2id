module FeatureToggles
  def self.allow_user_signup?
    ENV.fetch('ALLOW_USER_SIGNUP', 'true') == 'true'
  end
end
