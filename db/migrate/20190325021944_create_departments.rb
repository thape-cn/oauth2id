class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.integer :position
      t.integer :managed_by_department_id, foreign_key: true

      t.timestamps null: false
    end

    add_index :departments, :managed_by_department_id

    create_table :department_users do |t|
      t.references :department, null: false
      t.references :user, null: false

      t.timestamps null: false
    end
  end
end
