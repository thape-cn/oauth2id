class AddLoginUrlToDoorkeeperApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :login_url, :string
  end
end
