class AddDataDumper < ActiveRecord::Migration
  def change
    create_table :app_dumps do |t|
      t.references   :application
      t.string       "dbtype"
      t.string       "dbname"
      t.boolean      "daily", default: true
      t.boolean      "scrub", default: false
      t.text         "scrubbers"
      t.boolean      "in_progress", default: false
      t.datetime     "last_dumped_at"
      t.timestamps
    end
    add_index "app_dumps", ["application_id"], name: 'app_ndx'

    create_table :app_dump_logs do |t|
      t.integer     "app_dump_id"
      t.boolean     "success"
      t.datetime    "started_at"
      t.datetime    "finished_at"
      t.integer     "size"
      t.float       "runtime"
      t.text        "additionaldata"
      t.timestamps
    end

    add_index "app_dump_logs", ["app_dump_id"], name: 'app_dump_ndx'

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
        AppDump.create(application: application, dbtype: 'production', dbname: dbname, scrub: true)
      else
        AppDump.create(application: application, dbtype: 'production', dbname: dbname, scrub: false)
      end
    end

    # special case for dev_aae
    AppDump.create(application: Application.find_by_name('AaE'), dbtype: 'development', dbname: 'dev_aae', scrub: false)

  end

end
