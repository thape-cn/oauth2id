# frozen_string_literal: true

class JwtsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def index
    @allowlisted_jwts = @user.allowlisted_jwts
  end

  def create
    exp_seconds = params[:exp_hours].to_i.hours
    payload = jwt_payload(exp_seconds, params[:aud])
    jwt = Warden::JWTAuth::TokenEncoder.new.call(payload)
    Rails.logger.debug "jwt: #{jwt}"
    if @user.allowlisted_jwts.create(jti: payload['jti'], aud: payload['aud'], exp: Time.at(payload['exp']))
      redirect_to jwts_path, alert: t('.created', jwt: jwt)
    else
      render :index
    end
  end

  def destroy
    @jwt = @user.allowlisted_jwts.find(params[:id])
    @jwt.destroy!
    redirect_to jwts_path, notice: t('.deleted')
  end

  def clean_expired_jwts
    @user.allowlisted_jwts.where('exp < ?', Time.now).each(&:destroy)
    redirect_to jwts_path, notice: t('.done')
  end

  private

  def set_user
    @user = current_user
  end

  def jwt_payload(exp, aud)
    user_encoder = Warden::JWTAuth::UserEncoder.new
    payload = user_encoder.helper.payload_for_user(current_user, 'user')
    payload['exp'] = Time.now.to_i + exp.to_i
    payload['aud'] = aud
    payload
  end
end
