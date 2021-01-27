class CascadingDeletesForOauthOpenidRequests < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key(
      :oauth_openid_requests,
      :oauth_access_grants,
      column: :access_grant_id)

    add_foreign_key(
      :oauth_openid_requests,
      :oauth_access_grants,
      column: :access_grant_id,
      on_delete: :cascade)
  end
end
