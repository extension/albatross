class AddSnapshotSupport < ActiveRecord::Migration
  def change
    add_column('app_dumps','is_snapshot',:boolean,default: false)
    execute("UPDATE app_dumps SET is_snapshot = 0")
  end

end
