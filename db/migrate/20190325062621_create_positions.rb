class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.string :name
      t.string :functional_category

      t.timestamps
    end

    create_table :position_users do |t|
      t.references :position, null: false
      t.references :user, null: false
      t.boolean :main_position, default: false

      t.timestamps null: false
    end
  end
end
