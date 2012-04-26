class CreateCoders < ActiveRecord::Migration
  def change
    create_table :coders do |t|
      t.string   "uid",  :default => "",    :null => false
      t.string   "name",     :default => "",    :null => false
      t.string   "nickname",      :default => "",    :null => false
      t.string   "email",         :default => "",    :null => false
      t.datetime "last_login_at"
      t.timestamps
    end
    
    add_index "coders", ["email"], :unique => true
    
  end
end
