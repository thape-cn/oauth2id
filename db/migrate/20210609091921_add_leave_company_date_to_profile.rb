class AddLeaveCompanyDateToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :leave_company_date, :date
  end
end
