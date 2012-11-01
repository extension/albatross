class AddCoderToDumpLogs < ActiveRecord::Migration
  def change
    add_column('app_dump_logs', 'coder_id', :integer, default: 1)
    execute "UPDATE app_dump_logs SET coder_id = 1"
  end
end
