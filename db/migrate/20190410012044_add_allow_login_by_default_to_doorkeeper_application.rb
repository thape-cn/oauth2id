class AddAllowLoginByDefaultToDoorkeeperApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :allow_login_by_default, :boolean, default: false
  end
end
