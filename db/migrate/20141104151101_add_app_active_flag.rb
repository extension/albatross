class AddAppActiveFlag < ActiveRecord::Migration
  def change
    add_column(:applications, :is_active, :boolean, default: true)
  end
end
