class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.references :deployer
      t.references :application
      t.string   "previous_revision"
      t.string   "deployed_revision"
      t.string   "location"
      t.timestamps
    end
    
    add_index "deploys", ["deployer_id","application_id","location"], :name => 'search_ndx'
    
  end
end
