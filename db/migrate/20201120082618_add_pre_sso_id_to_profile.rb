class AddPreSsoIdToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :pre_sso_id, :string
  end
end
