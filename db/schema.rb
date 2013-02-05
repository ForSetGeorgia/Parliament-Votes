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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130205161402) do

  create_table "agendas", :force => true do |t|
    t.integer  "conference_id"
    t.integer  "sort_order",    :default => 0
    t.integer  "level"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agendas", ["conference_id"], :name => "index_agendas_on_conference_id"
  add_index "agendas", ["sort_order", "name"], :name => "index_agendas_on_sort_order_and_name"

  create_table "conferences", :force => true do |t|
    t.date     "start_date"
    t.string   "name"
    t.integer  "conference_label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conferences", ["start_date", "name"], :name => "index_conferences_on_start_date_and_name"

  create_table "delegates", :force => true do |t|
    t.integer  "group_id"
    t.string   "first_name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delegates", ["group_id"], :name => "index_delegates_on_group_id"

  create_table "groups", :force => true do |t|
    t.string   "text"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "voting_results", :force => true do |t|
    t.integer  "voting_session_id"
    t.integer  "delegate_id"
    t.boolean  "present"
    t.integer  "vote"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "voting_results", ["delegate_id"], :name => "index_voting_results_on_delegate_id"
  add_index "voting_results", ["voting_session_id"], :name => "index_voting_results_on_voting_session_id"

  create_table "voting_sessions", :force => true do |t|
    t.integer  "agenda_id"
    t.boolean  "passed"
    t.boolean  "quorum"
    t.integer  "result1",           :default => 0
    t.integer  "result3",           :default => 0
    t.integer  "result5",           :default => 0
    t.string   "result1text"
    t.string   "result3text"
    t.string   "result5text"
    t.string   "button1text"
    t.string   "button3text"
    t.text     "voting_conclusion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "voting_sessions", ["agenda_id"], :name => "index_voting_sessions_on_agenda_id"

end
