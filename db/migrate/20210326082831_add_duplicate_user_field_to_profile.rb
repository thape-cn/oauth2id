class AddDuplicateUserFieldToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :clerk_code, :string, if_not_exists: true
    add_column :profiles, :chinese_name, :string, if_not_exists: true
  end
end
