class AddDeployBranch < ActiveRecord::Migration
  def change
    add_column('deploys','branch',:string,default: '')

    Deploy.reset_column_information
    Deploy.all.each do |deploy|
      deploy.set_branch_from_log
    end
  end
end
