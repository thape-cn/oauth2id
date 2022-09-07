class HomelandSsoController < ApplicationController
  before_action :authenticate_user!

  def sso
    # sso_secret 需要和 Homeland 里面配置的 sso_secret 一致
    homeland_sso_secret = Rails.application.credentials[Rails.env.to_sym][:homeland_sso_secret]
    sso = HomelandSingleSignOn.parse(request.query_string, homeland_sso_secret)
    # 以下的信息将会提供给 Homeland 作为用户信息同步
    sso.email = current_user.email
    sso.name = current_user.profile&.chinese_name
    sso.username = current_user.username
    sso.bio = current_user.profile&.title
    sso.external_id = current_user.id
    sso.sso_secret = homeland_sso_secret

    # 最后将准备好的信息计算成加密的 URL Query String 并跳转到 Homeland 应用的 SSO 登录地址 '/auth/sso/login'
    # Homeland 接收到信息以后，将会实现同步账号登陆的流程
    redirect_to sso.to_url(Rails.application.credentials[Rails.env.to_sym][:homeland_url])
  end
end
