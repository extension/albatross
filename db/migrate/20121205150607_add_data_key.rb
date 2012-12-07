class AddDataKey < ActiveRecord::Migration
  def change
    add_column('coders','data_key',:string,default: '')
    add_index "coders", ["data_key"], name: 'data_key_ndx'

    # set the key
    Coder.reset_column_information
    Coder.all.each do |coder|
      coder.set_data_key
    end

  end
end
