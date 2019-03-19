class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.boolean :gender
      t.string :phone

      t.timestamps
    end
  end
end
