class AddYxtUserIdToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :yxt_user_id, :string
  end
end
