class AddCompanyCodeToDepartment < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :company_code, :string
  end
end
