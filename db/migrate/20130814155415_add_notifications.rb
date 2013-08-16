class AddNotifications < ActiveRecord::Migration
  def change

    create_table "notifications", :force => true do |t|
      t.integer  "notifiable_id"
      t.string   "notifiable_type",   :limit => 30
      t.integer  "notification_type",                                  :null => false
      t.datetime "delivery_time",                                      :null => false
      t.boolean  "processed",                       :default => false, :null => false
      t.boolean  "process_on_create",               :default => false
      t.text     "additionaldata"
      t.text     "results"
      t.datetime "created_at",                                         :null => false
      t.datetime "updated_at",                                         :null => false
    end

  end

end
