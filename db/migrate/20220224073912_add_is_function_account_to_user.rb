class AddIsFunctionAccountToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_function_account, :boolean, default: false
  end
end
