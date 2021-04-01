class AddBasePostToPosition < ActiveRecord::Migration[6.1]
  def change
    add_column :positions, :pk_poststd, :string
    add_column :positions, :b_postcode, :string
    add_column :positions, :b_postname, :string
  end
end
