class AddWecomIdToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :wecom_id, :string
  end
end
