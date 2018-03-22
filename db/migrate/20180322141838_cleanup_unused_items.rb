class CleanupUnusedItems < ActiveRecord::Migration
  def change
    remove_column(:app_locations,:is_aws)
    remove_column(:app_copies, :is_wordpress)
    remove_column(:app_dumps, :is_wordpress)
    remove_column(:app_dumps, :is_aws)
  end

  def down
  end
end
