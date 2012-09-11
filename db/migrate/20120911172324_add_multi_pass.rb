class AddMultiPass < ActiveRecord::Migration
  def change
    create_table :coder_emails do |t|
      t.references  :coder
      t.string   "email"
      t.timestamps
    end
    add_index "coder_emails", ["email"], :unique => true

    # update uid and create emails from coders
    execute "INSERT INTO coders (id,uid,name,nickname,email,created_at,updated_at) VALUES(1,'https://people.extension.org/eXtension','CoderBot','CoderBot','engineering@extension.org',NOW(),NOW())"
    
    # delete one of Jason's accounts
    execute "DELETE from coders where id = 9"

    # transfer emails and set uid's to eXtension
    CoderEmail.reset_column_information
    Coder.all.each do |coder|
      CoderEmail.create(coder_id: coder.id, email: coder.email)
      case coder.id
      when 2
        coder.update_attribute(:uid,'https://people.extension.org/sdnall')
      when 3
        coder.update_attribute(:uid,'https://people.extension.org/jayoung')
        # create an extra email for Jason
        CoderEmail.create(coder_id: coder.id, email: 'jasonadamyoung@gmail.com')
      when 5
        coder.update_attribute(:uid,'https://people.extension.org/athundle')
      when 6
        coder.update_attribute(:uid,'https://people.extension.org/idenev')
      when 7
        coder.update_attribute(:uid,'https://people.extension.org/benmac')
      else
        # nothing
      end
    end

    # drop email column on coders
    remove_column(:coders, :email)

    # add unique uid index
    add_index "coders", ["uid"], :name => "index_coders_on_uid", :unique => true

  end

end
