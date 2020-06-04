class Whitelist2Allowlist < ActiveRecord::Migration[5.2]
  def change
    rename_table('whitelisted_jwts', 'allowlisted_jwts')
  end
end
