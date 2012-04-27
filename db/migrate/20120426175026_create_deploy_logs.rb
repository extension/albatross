class CreateDeployLogs < ActiveRecord::Migration
  def change
    create_table :deploy_logs do |t|
      t.references :deploy
      t.text     "output",         :limit => 16777215
      t.timestamps
    end
    
    add_index "deploy_logs", ["deploy_id"], :name => 'deploy_ndx'
    
  end
end
