class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :preflighted

  def index
    from_saml_host = cookies["from_saml_host"]
    Rails.logger.debug "from_saml_host: #{from_saml_host}"
    case from_saml_host
    when "thape.zoom.us"
    when "thape.zoom.com.cn"
      redirect_to SamlIdp.config.service_provider.finder.call('https://thape.zoom.us')[:login_url]
    when "performancemanager15.sapsf.cn"
      redirect_to SamlIdp.config.service_provider.finder.call('www.successfactors.com')[:login_url]
    else
      @portal = Doorkeeper::Application.find_by!(id: 11)
      @applications = if current_user.present?
        user_allowed_application_ids = current_user.user_allowed_applications.where(enable: true).pluck(:oauth_application_id)
        Doorkeeper::Application.where(id: user_allowed_application_ids)
          .or(Doorkeeper::Application.where(allow_login_by_default: true)).where.not(id: 11)
      else
        Doorkeeper::Application.where.not(id: 11)
      end
    end
  end

  def logout
    sign_out(current_user) if current_user.present?
    redirect_to new_user_session_path, alert: "Logout success"
  end

  def preflighted
    headers['Access-Control-Allow-Origin'] = 'https://notes.thape.com.cn'
    headers['Access-Control-Allow-Headers'] = 'Accept, Content-Type, Authorization, Origin, Referer, User-Agent, JWT-AUD'
    render plain: ''
  end
end
