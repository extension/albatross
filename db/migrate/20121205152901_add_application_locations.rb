class AddApplicationLocations < ActiveRecord::Migration
  def change

    create_table :app_locations do |t|
      t.references  :application
      t.string      "location"
      t.string      "url"
      t.timestamps
    end

    add_index "app_locations", ["application_id","location"], name: 'app_loc_ndx', unique: true

    # data
    AppLocation.reset_column_information
    
    applist = {}
    Application.all.each do |app|
      applist[app.name.downcase] = app.id
    end

    AppLocation.create(application_id: applist['darmok'], location: 'production', url: 'http://www.extension.org')
    AppLocation.create(application_id: applist['darmok'], location: 'development', url: 'http://www.demo.extension.org')
    AppLocation.create(application_id: applist['learn'], location: 'production', url: 'https://learn.extension.org')
    AppLocation.create(application_id: applist['learn'], location: 'development', url: 'http://dev.learn.extension.org')
    AppLocation.create(application_id: applist['albatross'], location: 'production', url: 'http://deploys.extension.org')
    AppLocation.create(application_id: applist['aae'], location: 'production', url: 'https://ask.extension.org')
    AppLocation.create(application_id: applist['aae'], location: 'development', url: 'http://dev.ask.extension.org')
    AppLocation.create(application_id: applist['create'], location: 'production', url: 'http://create.extension.org')
    AppLocation.create(application_id: applist['create'], location: 'development', url: 'http://create.demo.extension.org')
    AppLocation.create(application_id: applist['positronic'], location: 'production', url: 'http://data.extension.org')
    AppLocation.create(application_id: applist['about'], location: 'production', url: 'http://about.extension.org')
    AppLocation.create(application_id: applist['about'], location: 'development', url: 'http://about.demo.extension.org')
    AppLocation.create(application_id: applist['milfam'], location: 'production', url: 'http://militaryfamilies.extension.org')
    AppLocation.create(application_id: applist['milfam'], location: 'development', url: 'http://militaryfamilies.demo.extension.org')
    AppLocation.create(application_id: applist['blogs'], location: 'production', url: 'http://blogs.extension.org')
    AppLocation.create(application_id: applist['nexc2012'], location: 'production', url: 'http://nexc2012.extension.org')
    AppLocation.create(application_id: applist['apperrors'], location: 'production', url: 'http://apperrors.extension.org')

  end

end
