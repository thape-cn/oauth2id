SamlIdp.configure do |config|
  if Rails.env.development?
    base = 'https://oauth2id.test'
  else
    base = 'https://oauth2id.dev'
  end

  config.x509_certificate = Rails.application.credentials.oauth2id_x509_certificate!

  config.secret_key = Rails.application.credentials.oauth2id_x509_secret_key!

  # NameIDFormat
  config.name_id.formats = {
    "1.1" => {
      unspecified: -> (principal) { principal.email },
    },
    "2.0" => {
      transient: -> (principal) { principal.email_address },
      persistent: -> (p) { p.id },
    },
  }

  service_providers = {
    "https://saml-example.test/saml/metadata" => {
      fingerprint: Rails.application.credentials.oauth2id_x509_sha256_fingerprint!,
      metadata_url: "https://saml-example.test/saml/metadata",
      assertion_consumer_logout_service_url: "https://saml-example.test/saml/logout",
      cert: Base64.encode64(Rails.application.credentials.saml_sp_cert!)
    },
    "www.successfactors.com" => {
      fingerprint: Rails.application.credentials.oauth2id_x509_sha256_fingerprint!,
      response_hosts: ["performancemanager15.sapsf.cn"],
      acs_url: 'https://performancemanager15.sapsf.cn/saml2/SAMLAssertionConsumer?company=shanghaiti',
      assertion_consumer_logout_service_url: "https://performancemanager15.sapsf.cn/saml2/LogoutServiceHTTPRedirect?company=shanghaiti",
      cert: Base64.encode64(Rails.application.credentials.saml_shti_sp_cert!)
    },
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # settings is an IncomingMetadata object which has a to_h method that needs to be persisted
  config.service_provider.metadata_persister = ->(identifier, settings) {
    fname = identifier.to_s.gsub(/\/|:/,"_")
    FileUtils.mkdir_p(Rails.root.join('cache', 'saml', 'metadata').to_s)
    File.open Rails.root.join("cache/saml/metadata/#{fname}"), "r+b" do |f|
      Marshal.dump settings.to_h, f
    end
  }

  # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # `service_provider` you should return the settings.to_h from above
  config.service_provider.persisted_metadata_getter = ->(identifier, service_provider){
    fname = identifier.to_s.gsub(/\/|:/,"_")
    FileUtils.mkdir_p(Rails.root.join('cache', 'saml', 'metadata').to_s)
    full_filename = Rails.root.join("cache/saml/metadata/#{fname}")
    if File.file?(full_filename)
      File.open full_filename, "rb" do |f|
        Marshal.load f
      end
    end
  }

  # Find ServiceProvider metadata_url and fingerprint based on our settings
  config.service_provider.finder = ->(issuer_or_entity_id) do
    Rails.logger.debug "Find ServiceProvider issuer_or_entity_id: #{issuer_or_entity_id}"
    service_providers[issuer_or_entity_id]
  end
end
