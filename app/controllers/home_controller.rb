class HomeController < ApplicationController
  def index
    from_saml_host = cookies["from_saml_host"]
    Rails.logger.debug "from_saml_host: #{from_saml_host}"
    case from_saml_host
    when "thape.zoom.us"
      redirect_to SamlIdp.config.service_provider.finder.call('https://thape.zoom.us')[:login_url]
    when "performancemanager15.sapsf.cn"
      redirect_to SamlIdp.config.service_provider.finder.call('www.successfactors.com')[:login_url]
    else
      @applications = if current_user.present?
        user_allowed_application_ids = current_user.user_allowed_applications.where(enable: true).pluck(:oauth_application_id)
        Doorkeeper::Application.where(id: user_allowed_application_ids)
          .or(Doorkeeper::Application.where(allow_login_by_default: true))
      else
        Doorkeeper::Application.all
      end
    end
  end
end
