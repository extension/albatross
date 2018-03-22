class ChangeWordpressFlag < ActiveRecord::Migration
  def change
    # change where wordpress flag is
    add_column(:applications, :is_wordpress, :boolean, default: false)
    execute("UPDATE applications,app_copies SET applications.is_wordpress = app_copies.is_wordpress WHERE applications.id = app_copies.application_id")
  end
end
