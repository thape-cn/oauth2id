class AddSuperAppToDoorkeeperApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :superapp, :boolean, default: false
  end
end
