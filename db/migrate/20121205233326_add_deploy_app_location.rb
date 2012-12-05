class AddDeployAppLocation < ActiveRecord::Migration
  def change
    add_column('deploys','app_location_id',:integer,default: 0)

    # set everything that's "staging" to development
    execute "UPDATE deploys SET location = 'development' where location = 'staging'"

    # associate an app_location_id
    execute "UPDATE deploys,app_locations SET deploys.app_location_id = app_locations.id WHERE deploys.application_id = app_locations.application_id AND deploys.location = app_locations.location"

  end
end
