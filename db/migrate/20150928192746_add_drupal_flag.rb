class AddDrupalFlag < ActiveRecord::Migration
  def change
    add_column(:app_dumps, :is_drupal, :boolean, default: false)
    add_column(:app_copies, :is_drupal, :boolean, default: false)
  end

end
