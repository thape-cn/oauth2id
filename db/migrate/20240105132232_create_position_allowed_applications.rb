class CreatePositionAllowedApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :position_allowed_applications do |t|
      t.references :position, null: false, foreign_key: true
      t.references :oauth_application, null: false, foreign_key: true

      t.timestamps
    end
  end
end
