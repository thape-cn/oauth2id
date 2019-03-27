class ApplicationController < ActionController::Base
  include Pundit
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
end
