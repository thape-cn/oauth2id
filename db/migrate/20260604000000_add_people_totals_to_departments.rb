class AddPeopleTotalsToDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :company_total_people, :integer, default: 0, null: false
    add_column :departments, :department_total_people, :integer, default: 0, null: false
  end
end
