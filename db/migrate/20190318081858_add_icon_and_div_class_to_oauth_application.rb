class AddIconAndDivClassToOauthApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :icon, :string, default: 'fa-star'
    add_column :oauth_applications, :div_class, :string, default: 'primary'
  end
end
