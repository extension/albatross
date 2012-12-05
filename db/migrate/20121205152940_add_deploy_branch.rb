class AddDeployBranch < ActiveRecord::Migration
  def change
    add_column('deploys','branch',:string,default: '')
  end
end
