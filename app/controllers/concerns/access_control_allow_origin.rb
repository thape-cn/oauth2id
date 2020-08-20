module AccessControlAllowOrigin
  extend ActiveSupport::Concern

  def oauth2id_allow_origin
    if request.base_url == 'http://localhost:4000'
      'http://localhost:8000'
    elsif request.base_url == 'https://sso.thape.com.cn'
      'https://notes.thape.com.cn'
    end
  end
end
