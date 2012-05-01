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

ActiveRecord::Schema.define(:version => 20120501125539) do

  create_table "applications", :force => true do |t|
    t.string   "name"
    t.string   "github_url"
    t.string   "appkey"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "coders", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "nickname"
    t.string   "email"
    t.datetime "last_login_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "coders", ["email"], :name => "index_coders_on_email", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "deploy_logs", :force => true do |t|
    t.integer  "deploy_id"
    t.text     "output",     :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "deploy_logs", ["deploy_id"], :name => "deploy_ndx"

  create_table "deploys", :force => true do |t|
    t.string   "capatross_id"
    t.integer  "coder_id"
    t.integer  "application_id"
    t.string   "previous_revision"
    t.string   "deployed_revision"
    t.string   "location"
    t.datetime "start"
    t.datetime "finish"
    t.boolean  "success"
    t.text     "comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "deploys", ["capatross_id"], :name => "capatross_ndx", :unique => true
  add_index "deploys", ["coder_id", "application_id", "location"], :name => "search_ndx"

end
