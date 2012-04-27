class CreateCoders < ActiveRecord::Migration
  def change
    create_table :coders do |t|
      t.string   "uid"
      t.string   "name"
      t.string   "nickname"
      t.string   "email"
      t.datetime "last_login_at"
      t.timestamps
    end
    
    add_index "coders", ["email"], :unique => true
    
  end
end
