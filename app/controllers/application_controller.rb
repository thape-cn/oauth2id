class ApplicationController < ActionController::Base
  include Pundit

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protected

    def render_csv_header(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      if /msie/i.match?(request.env['HTTP_USER_AGENT'])
        headers['Pragma'] = 'public'
        headers['Content-type'] = 'text/plain'
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = '0'
      else
        headers['Content-Type'] ||= 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      end
    end
end
