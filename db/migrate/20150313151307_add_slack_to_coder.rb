class AddSlackToCoder < ActiveRecord::Migration
  def change
    add_column(:coders, :slack_user_id, :string)
  end
end
