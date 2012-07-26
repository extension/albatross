class CreateCrons < ActiveRecord::Migration
  def change
    create_table :crons do |t|
      t.string      "name"
      t.boolean     "notify_on_error"
      t.timestamps
    end
  end
end
