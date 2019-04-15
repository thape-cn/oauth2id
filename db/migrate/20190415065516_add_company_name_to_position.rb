class AddCompanyNameToPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :company_name, :string
  end
end
