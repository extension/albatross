class AddDataCenterToDbSource < ActiveRecord::Migration
  def change
    add_column(:app_dumps, :is_aws, :boolean, default: false)
    add_column(:app_locations, :is_aws, :boolean, default: false)
  end
end
