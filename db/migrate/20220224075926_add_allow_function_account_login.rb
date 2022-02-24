class AddAllowFunctionAccountLogin < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :allow_function_account_login, :boolean, default: false
  end
end
