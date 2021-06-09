# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_09_091921) do

  create_table "allowlisted_jwts", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud", null: false
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "department_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_department_users_on_department_id"
    t.index ["user_id"], name: "index_department_users_on_user_id"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position"
    t.integer "managed_by_department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dept_code"
    t.string "nc_pk_dept"
    t.string "nc_pk_fatherorg"
    t.string "company_name"
    t.integer "enablestate"
    t.string "hrcanceled", limit: 1
    t.string "company_code"
    t.string "dept_category"
  end

  create_table "oauth_access_grants", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon", default: "fa-star"
    t.string "div_class", default: "primary"
    t.string "login_url"
    t.boolean "allow_login_by_default", default: false
    t.boolean "superapp", default: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "fk_rails_77114b3b09"
  end

  create_table "position_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "position_id", null: false
    t.bigint "user_id", null: false
    t.boolean "main_position", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_level"
    t.string "job_type_code"
    t.index ["position_id"], name: "index_position_users_on_position_id"
    t.index ["user_id"], name: "index_position_users_on_user_id"
  end

  create_table "positions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "functional_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nc_pk_post"
    t.bigint "department_id"
    t.string "company_name"
    t.string "pk_poststd"
    t.string "b_postcode"
    t.string "b_postname"
    t.index ["department_id"], name: "index_positions_on_department_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.boolean "gender"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "clerk_code"
    t.string "chinese_name"
    t.integer "job_level"
    t.date "birthdate"
    t.date "entry_company_date"
    t.string "pre_sso_id"
    t.string "wecom_id"
    t.string "major_code"
    t.string "major_name"
    t.date "leave_company_date"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "user_allowed_applications", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "oauth_application_id"
    t.boolean "enable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oauth_application_id"], name: "index_user_allowed_applications_on_oauth_application_id"
    t.index ["user_id"], name: "index_user_allowed_applications_on_user_id"
  end

  create_table "user_sign_in_histories", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "sign_in_at"
    t.text "user_agent"
    t.string "sign_in_ip"
    t.index ["user_id"], name: "index_user_sign_in_histories_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "username"
    t.string "remember_token"
    t.string "desk_phone"
    t.bigint "yxt_position_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["yxt_position_id"], name: "index_users_on_yxt_position_id"
  end

  create_table "wechat_event_histories", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.integer "create_time"
    t.string "event"
    t.string "change_type"
    t.string "job_id"
    t.string "user_id"
    t.string "party_id"
    t.string "tag_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "yxt_positions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "position_name"
    t.string "prefix_paths"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", on_delete: :cascade
  add_foreign_key "positions", "departments"
  add_foreign_key "profiles", "users"
  add_foreign_key "user_allowed_applications", "oauth_applications"
  add_foreign_key "user_allowed_applications", "users"
  add_foreign_key "user_sign_in_histories", "users"
end
