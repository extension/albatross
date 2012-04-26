class CreateDeployLogs < ActiveRecord::Migration
  def change
    create_table :deploy_logs do |t|

      t.timestamps
    end
  end
end
