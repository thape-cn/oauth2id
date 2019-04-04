class AddMoreFieldToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :clerk_code, :string
    add_column :profiles, :chinese_name, :string
  end
end
