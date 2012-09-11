class CreateCrons < ActiveRecord::Migration
  def change
    create_table :crons do |t|
      t.string      "name", :null => false
      t.boolean     "notify_on_error", :null => false, :default => true
      t.timestamps
    end
  end
end
