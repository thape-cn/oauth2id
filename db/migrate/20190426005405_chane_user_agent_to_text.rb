class ChaneUserAgentToText < ActiveRecord::Migration[5.2]
  def change
    change_column(:user_sign_in_histories, :user_agent, :text)
  end
end
