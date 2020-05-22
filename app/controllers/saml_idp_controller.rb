class SamlIdpController < SamlIdp::IdpController
  before_action :authenticate_user!, except: [:show, :logout_response]

  # override create and make sure to set both "GET" and "POST" requests to /saml/auth to #create
  def create
    if user_signed_in?
      @saml_response = idp_make_saml_response(current_user)
      render :template => "saml_idp/idp/saml_post", :layout => false
      return
    else
      # it shouldn't be possible to get here, but lets render 403 just in case
      render :status => :forbidden
    end
  end

  def logout_response
    rexml = REXML::Document.new(params["SAMLResponse"])
    node = REXML::XPath.first(
      rexml,
      "/p:LogoutResponse",
      { "p" => "urn:oasis:names:tc:SAML:2.0:protocol" }
    )
    destination = node.nil? ? root_path : node.attributes['Destination']
    redirect_to destination
  end

  # NOT USED def idp_authenticate(email, password)

  def idp_make_saml_response(found_user) # not using params intentionally
    if saml_request.issuer == 'onelogin_saml'
      encode_response found_user
    elsif saml_request.issuer == 'https://thape.zoom.us'
      encode_response found_user
    else
      encode_response found_user, encryption: {
        cert: saml_request.service_provider.cert,
        block_encryption: 'aes256-cbc',
        key_transport: 'rsa-oaep-mgf1p'
      }
    end
  end
  private :idp_make_saml_response

  def idp_logout
    decode_request params[:SAMLRequest]
    user = User.find_by email: saml_request.name_id
    sign_out user
  end
  private :idp_logout
end
