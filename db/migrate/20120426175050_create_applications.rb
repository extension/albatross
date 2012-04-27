class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string   "name"
      t.string   "github_url"
      t.string   "appkey"
      t.timestamps
    end
  end
end
