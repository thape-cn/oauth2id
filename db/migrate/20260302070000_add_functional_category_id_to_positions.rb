class AddFunctionalCategoryIdToPositions < ActiveRecord::Migration[7.1]
  def change
    add_column :positions, :functional_category_id, :string
  end
end
