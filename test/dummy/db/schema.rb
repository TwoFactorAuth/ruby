# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141224135949) do

  create_table "two_factor_auth_registrations", force: true do |t|
    t.integer  "login_id",                                              null: false
    t.string   "login_type",                                            null: false
    t.binary   "key_handle",            limit: 65,                      null: false
    t.binary   "public_key",            limit: 10240,                   null: false
    t.binary   "certificate",           limit: 1048576, default: "x''", null: false
    t.integer  "counter",               limit: 5,       default: 0,     null: false
    t.datetime "last_authenticated_at",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "two_factor_auth_registrations", ["key_handle"], name: "index_two_factor_auth_registrations_on_key_handle"
  add_index "two_factor_auth_registrations", ["last_authenticated_at"], name: "index_two_factor_auth_registrations_on_last_authenticated_at"
  add_index "two_factor_auth_registrations", ["login_id", "login_type"], name: "index_two_factor_auth_registrations_on_login_id_and_login_type"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
