class LastActiveAt < ActiveRecord::Migration
  def change
    add_column('coders','last_active_at',:datetime)
  end
end
