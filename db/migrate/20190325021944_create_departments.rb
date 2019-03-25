class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.integer :position
      t.references :managed_by_department, foreign_key: true

      t.timestamps null: false
    end

    create_table :department_users do |t|
      t.references :department, null: false
      t.references :user, null: false

      t.timestamps null: false
    end
  end
end
