class AddAppCopies < ActiveRecord::Migration
  def change

    create_table "app_copies", :force => true do |t|
      t.integer  "application_id"
      t.boolean  "daily",                   :default => false
      t.boolean  "in_progress",             :default => false
      t.datetime "last_copy_at"
      t.integer  "last_copy_size",        :default => 0
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
    end

    add_index "app_copies", ["application_id"], name: "app_ndx", unique: true

    create_table "app_copy_logs", :force => true do |t|
      t.integer  "app_copy_id"
      t.integer  "coder_id",       :default => 1
      t.boolean  "success"
      t.datetime "started_at"
      t.datetime "finished_at"
      t.integer  "size"
      t.float    "runtime"
      t.text     "additionaldata"
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
    end

    add_index "app_copy_logs", ["app_copy_id"], name: "app_copy_ndx"


    Application.all.each do |application|
      if(dev_location = application.app_location_for_location(AppLocation::DEVELOPMENT))  
        AppCopy.create(application: application)
      end
    end

  end
end
