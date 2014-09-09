class BigSizes < ActiveRecord::Migration
  def up
    change_column(:app_copies, :last_copy_size, :bigint)
    change_column(:app_copy_logs, :size, :bigint)
  end

end
