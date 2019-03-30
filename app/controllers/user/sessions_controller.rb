class User::SessionsController < Devise::SessionsController
  layout 'sessions'

  def create
    super do |user|
      user.user_sign_in_histories
        .create(sign_in_at: Time.current,
                user_agent: request.user_agent, sign_in_ip: request.remote_ip)
    end
  end
end
