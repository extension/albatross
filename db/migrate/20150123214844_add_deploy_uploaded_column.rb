class AddDeployUploadedColumn < ActiveRecord::Migration
  def change
    add_column(:deploys, :uploaded, :boolean, default: false)
  end
end
