class AddCodeToDepartment < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :dept_code, :string
    add_column :departments, :nc_pk_dept, :string
    add_column :departments, :nc_pk_fatherorg, :string
    add_column :departments, :company_name, :string
    add_column :departments, :enablestate, :integer
    add_column :departments, :hrcanceled, :string, limit: 1
  end
end
