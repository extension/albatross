class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.string     "capatross_id"
      t.references :deployer
      t.references :application
      t.string     "previous_revision"
      t.string     "deployed_revision"
      t.string     "location"
      t.datetime   "start"
      t.datetime   "finish"
      t.boolean    "success"
      t.timestamps
    end

    add_index "deploys", ["capatross_id"], :name => 'capatross_ndx', :unique => true
    add_index "deploys", ["deployer_id","application_id","location"], :name => 'search_ndx'
    
  end
end
