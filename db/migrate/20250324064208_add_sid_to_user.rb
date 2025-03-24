class AddSidToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :windows_sid, :string
  end
end
