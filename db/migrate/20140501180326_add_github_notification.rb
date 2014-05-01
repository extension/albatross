class AddGithubNotification < ActiveRecord::Migration
  def change
    create_table :github_notifications do |t|
      t.references :coder
      t.references :application
      t.string     "branch"
      t.text       "payload",         :limit => 16777215
      t.datetime   "created_at"
    end

    add_column('coders','github_name',:string)
    add_column('applications','fetch_pending',:boolean, default: false)


  end
end
