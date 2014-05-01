class AddSomeFlags < ActiveRecord::Migration
  def change
    add_column('cronmon_servers','is_active',:boolean, default: true)
  end
end
