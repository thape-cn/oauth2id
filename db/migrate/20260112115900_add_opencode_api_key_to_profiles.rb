class AddOpencodeAPIKeyToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :opencode_api_key, :string
  end
end
