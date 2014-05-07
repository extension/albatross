class AddGitFetches < ActiveRecord::Migration
  def change
    create_table :git_fetches do |t|
      t.references  :application
      t.text        "stdout"
      t.text        "stderr"
      t.string      "command"
      t.datetime    "started_at"
      t.datetime    "finished_at"
      t.float       "runtime"
      t.datetime    "created_at"
    end
  end
end
