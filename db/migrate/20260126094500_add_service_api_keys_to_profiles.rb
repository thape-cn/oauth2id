class AddServiceAPIKeysToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :kimi_api_key, :string
    add_column :profiles, :siliconflow_cn_api_key, :string
    add_column :profiles, :moonshot_api_key, :string
    add_column :profiles, :exa_api_key, :string
    add_column :profiles, :deepseek_api_key, :string
    add_column :profiles, :cerebras_api_key, :string
  end
end
