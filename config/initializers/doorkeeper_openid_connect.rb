Doorkeeper::OpenidConnect.configure do
  if Rails.env.development?
    issuer 'https://oauth2id.test/'
  else
    issuer Rails.application.credentials.oauth2id_issuer!
  end

  signing_key Rails.application.credentials.oauth2id_signing_key!

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    # Example implementation:
    User.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  subject do |resource_owner, application|
    # Example implementation:
    resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    # Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  protocol do
    :https
  end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  claims do
    normal_claim :name, scope: :openid do |resource_owner|
      resource_owner.username
    end
    normal_claim :email, scope: :openid do |resource_owner|
      resource_owner.email
    end
    normal_claim :gender, scope: :openid do |resource_owner|
      profile = resource_owner.profile
      if profile.present?
        profile.gender ? 'Male' : 'Female'
      end
    end
    normal_claim :phone_number, scope: :phone do |resource_owner|
      resource_owner.profile&.phone
    end

    normal_claim :clerk_code, scope: :clerk_code do |resource_owner|
      resource_owner.profile&.clerk_code
    end

    normal_claim :chinese_name, scope: :chinese_name do |resource_owner|
      resource_owner.profile&.chinese_name
    end

    normal_claim :departments, scope: :departments do |resource_owner|
      resource_owner.departments.collect do |department|
        { id: department.id, name: department.name, company_name: department.company_name }
      end
    end

    normal_claim :positions, scope: :positions do |resource_owner|
      positions = resource_owner.positions.collect do |position|
        { id: position.id, name: position.name, functional_category: position.functional_category }
      end
    end

    normal_claim :main_position, scope: :main_position do |resource_owner|
      main_position = resource_owner.position_users.find_by(main_position: true)&.position
      main_position = resource_owner.positions.last if main_position.nil?
      if main_position.present?
        { id: main_position.id, name: main_position.name, functional_category: main_position.functional_category }
      end
    end
  end
end
