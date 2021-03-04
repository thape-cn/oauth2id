class AddDeptCDategoryToDepartment < ActiveRecord::Migration[6.0]
  def change
    add_column :departments, :dept_category, :string
  end
end
