class CreateUserAllowedApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :user_allowed_applications do |t|
      t.references :user, foreign_key: true
      t.references :oauth_application, foreign_key: true
      t.boolean :enable, default: true

      t.timestamps
    end
  end
end
