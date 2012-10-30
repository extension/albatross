class AddDataDumper < ActiveRecord::Migration
  def change
    create_table :app_data do |t|
      t.references   :application
      t.string       "dbtype"
      t.string       "dbname"
      t.boolean      "scrub", default: false
      t.text         "scrubbers"
      t.datetime     "last_dumped_at"
      t.timestamps
    end
    add_index "app_data", ["application_id"], name: 'app_ndx'

    # initial seed
    apps_and_dbs = {}
    apps_and_dbs['Darmok'] = 'prod_darmok'
    apps_and_dbs['Learn'] = 'prod_learn'
    apps_and_dbs['Albatross'] = 'prod_deploys'
    apps_and_dbs['Create'] = 'prod_create'
    apps_and_dbs['Positronic'] = 'prod_data'
    apps_and_dbs.each do |appname,dbname|
      application = Application.find_by_name(appname)
      if(['Darmok','Create'].include?(appname))
        AppData.create(application: application, dbtype: 'production', dbname: dbname, scrub: true)
      else
        AppData.create(application: application, dbtype: 'production', dbname: dbname, scrub: false)
      end
    end

  end

end
