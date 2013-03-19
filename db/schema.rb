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

ActiveRecord::Schema.define(:version => 20130319054456) do

  create_table "agendas", :force => true do |t|
    t.integer  "conference_id"
    t.integer  "sort_order",              :default => 0
    t.integer  "level"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "xml_id"
    t.boolean  "is_law",                  :default => false
    t.string   "registration_number"
    t.string   "session_number"
    t.integer  "number_possible_members", :default => 150
    t.string   "law_url"
    t.string   "law_id"
    t.string   "law_title"
    t.string   "official_law_title"
    t.text     "law_description"
    t.integer  "parliament_id"
  end

  add_index "agendas", ["conference_id"], :name => "index_agendas_on_conference_id"
  add_index "agendas", ["is_law"], :name => "index_agendas_on_is_law"
  add_index "agendas", ["law_id"], :name => "index_agendas_on_law_id"
  add_index "agendas", ["law_url"], :name => "index_agendas_on_law_url"
  add_index "agendas", ["number_possible_members"], :name => "index_agendas_on_number_possible_members"
  add_index "agendas", ["parliament_id"], :name => "index_agendas_on_parliament_id"
  add_index "agendas", ["sort_order", "name"], :name => "index_agendas_on_sort_order_and_name"

  create_table "all_delegates", :force => true do |t|
    t.integer  "xml_id"
    t.integer  "group_id"
    t.string   "first_name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "all_delegates", ["xml_id"], :name => "index_all_delegates_on_xml_id"

  create_table "conferences", :force => true do |t|
    t.date     "start_date"
    t.string   "name"
    t.integer  "conference_label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upload_file_id"
    t.integer  "number_laws",      :default => 0
    t.integer  "number_sessions",  :default => 0
  end

  add_index "conferences", ["start_date", "name"], :name => "index_conferences_on_start_date_and_name"
  add_index "conferences", ["upload_file_id"], :name => "index_conferences_on_upload_file_id"

  create_table "delegates", :force => true do |t|
    t.integer  "group_id"
    t.string   "first_name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conference_id"
    t.integer  "xml_id"
  end

  add_index "delegates", ["conference_id"], :name => "index_delegates_on_conference_id"
  add_index "delegates", ["group_id"], :name => "index_delegates_on_group_id"

  create_table "groups", :force => true do |t|
    t.integer  "conference_id"
    t.string   "text"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "xml_id"
  end

  add_index "groups", ["conference_id"], :name => "index_groups_on_conference_id"

  create_table "parliaments", :force => true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parliaments", ["name"], :name => "index_parliaments_on_name"
  add_index "parliaments", ["start_date"], :name => "index_parliaments_on_start_date"

  create_table "upload_files", :force => true do |t|
    t.string   "xml_file_name"
    t.string   "xml_content_type"
    t.string   "xml_file_size"
    t.string   "xml_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "file_processed"
    t.integer  "number_possible_members", :default => 150
    t.integer  "parliament_id"
    t.boolean  "is_deleted",              :default => false
    t.datetime "deleted_at"
    t.integer  "deleted_by_id"
  end

  add_index "upload_files", ["file_processed"], :name => "index_upload_files_on_file_processed"
  add_index "upload_files", ["is_deleted"], :name => "index_upload_files_on_is_deleted"
  add_index "upload_files", ["number_possible_members"], :name => "index_upload_files_on_number_possible_members"
  add_index "upload_files", ["parliament_id"], :name => "index_upload_files_on_parliament_id"

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

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "voting_results", :force => true do |t|
    t.integer  "voting_session_id"
    t.integer  "delegate_id"
    t.boolean  "present"
    t.integer  "vote"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_edited",         :default => false
    t.boolean  "is_manual_add",     :default => false
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
    t.integer  "xml_id"
    t.integer  "result0",           :default => 0
    t.integer  "not_present",       :default => 0
  end

  add_index "voting_sessions", ["agenda_id"], :name => "index_voting_sessions_on_agenda_id"
  add_index "voting_sessions", ["passed"], :name => "index_voting_sessions_on_passed"

end
