class AddApplicationLocations < ActiveRecord::Migration
  def change

    create_table :app_locations do |t|
      t.references  :application
      t.string   "location"
      t.string   "url"
      t.string   "dbname"
      t.timestamps
    end

    add_index "app_locations", ["application_id","location"], name: 'app_loc_ndx', unique: true

    # data
    AppLocation.reset_column_information
    
    applist = {}
    Application.all.each do |app|
      applist[app.name.downcase] = app.id
    end

    AppLocation.create(application_id: applist['darmok'], location: 'production', url: 'http://www.extension.org', dbname: 'prod_darmok')
    AppLocation.create(application_id: applist['darmok'], location: 'development', url: 'http://www.demo.extension.org', dbname: 'demo_darmok')
    AppLocation.create(application_id: applist['learn'], location: 'production', url: 'https://learn.extension.org', dbname: 'prod_learn')
    AppLocation.create(application_id: applist['learn'], location: 'development', url: 'http://dev.learn.extension.org', dbname: 'dev_learn')
    AppLocation.create(application_id: applist['albatross'], location: 'production', url: 'http://deploys.extension.org', dbname: 'prod_deploys')
    AppLocation.create(application_id: applist['aae'], location: 'production', url: 'https://ask.extension.org', dbname: 'prod_aae')
    AppLocation.create(application_id: applist['aae'], location: 'development', url: 'http://dev.ask.extension.org', dbname: 'dev_aae')
    AppLocation.create(application_id: applist['create'], location: 'production', url: 'http://create.extension.org', dbname: 'prod_create')
    AppLocation.create(application_id: applist['create'], location: 'development', url: 'http://create.demo.extension.org', dbname: 'demo_create')
    AppLocation.create(application_id: applist['positronic'], location: 'production', url: 'http://data.extension.org', dbname: 'prod_data')
    AppLocation.create(application_id: applist['about'], location: 'production', url: 'http://about.extension.org', dbname: 'prod_aboutblog')
    AppLocation.create(application_id: applist['about'], location: 'development', url: 'http://about.demo.extension.org', dbname: 'demo_aboutblog')
    AppLocation.create(application_id: applist['milfam'], location: 'production', url: 'http://militaryfamilies.extension.org', dbname: 'prod_milfam')
    AppLocation.create(application_id: applist['milfam'], location: 'development', url: 'http://militaryfamilies.demo.extension.org', dbname: 'demo_milfam')
    AppLocation.create(application_id: applist['blogs'], location: 'production', url: 'http://blogs.extension.org', dbname: 'prod_wordpressmu')
    AppLocation.create(application_id: applist['nexc2012'], location: 'production', url: 'http://nexc2012.extension.org', dbname: 'prod_nexc2012')
    AppLocation.create(application_id: applist['apperrors'], location: 'production', url: 'http://apperrors.extension.org')

    # app_dump association
    execute "ALTER TABLE `prod_deploys`.`app_dumps` ADD COLUMN `app_location_id` INT(11) NULL DEFAULT 0  AFTER `application_id`;"
    execute "UPDATE app_locations,app_dumps SET app_locations.dbname = app_dumps.dbname, app_dumps.app_location_id = app_locations.id WHERE app_locations.application_id = app_dumps.application_id and app_dumps.dbtype = app_locations.location"

    # deploys association
    add_column('deploys','app_location_id',:integer,default: 0)

    # set everything that's "staging" to development
    execute "UPDATE deploys SET location = 'development' where location = 'staging'"

    # associate an app_location_id
    execute "UPDATE deploys,app_locations SET deploys.app_location_id = app_locations.id WHERE deploys.application_id = app_locations.application_id AND deploys.location = app_locations.location"

  end

end
