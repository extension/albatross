class ChangeToStaging < ActiveRecord::Migration
  def change
    # data changing migration
    execute "UPDATE app_locations SET location='staging' WHERE location='development'"
    execute "UPDATE app_dumps SET dbtype='staging' WHERE dbtype='development'"
    execute "UPDATE deploys SET location='staging' WHERE location='development'"
  end
end
