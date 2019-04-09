class AddMoreFieldToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :clerk_code, :string
    add_column :profiles, :chinese_name, :string
    add_column :profiles, :job_level, :string
    add_column :profiles, :birthdate, :date
    add_column :profiles, :entry_company_date, :date
  end
end
