class AddDeskPhoneToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :desk_phone, :string
  end
end
