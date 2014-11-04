class AddWordpressFlag < ActiveRecord::Migration
  def change
    add_column(:app_dumps, :is_wordpress, :boolean, default: false)
    add_column(:app_copies, :is_wordpress, :boolean, default: false)
  end
end
