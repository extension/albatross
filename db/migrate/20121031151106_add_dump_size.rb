class AddDumpSize < ActiveRecord::Migration
  def change
    add_column('app_dumps','last_dump_size',:integer,default: 0)
  end
end
