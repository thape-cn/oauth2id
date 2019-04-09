class AddDepartmentIdToPosition < ActiveRecord::Migration[5.2]
  def change
    add_reference :positions, :department, foreign_key: true
  end
end
