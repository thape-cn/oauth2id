class AddYxtOpenIdsToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :yxt_open_id, :string
    add_column :profiles, :wecom_yxt_open_id, :string
  end
end
