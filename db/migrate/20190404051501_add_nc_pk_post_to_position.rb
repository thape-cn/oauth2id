class AddNcPkPostToPosition < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :nc_pk_post, :string
  end
end
