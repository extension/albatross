class AddWordpressRewrites < ActiveRecord::Migration
  def change

    create_table "app_url_rewrites", :force => true do |t|
      t.integer  "application_id"
      t.string   "location"
      t.string   "search_host"
      t.string   "replace_host"
      t.datetime "created_at",                                     :null => false
    end
    add_index "app_url_rewrites", ["application_id", "location"], :name => "app_loc_ndx"

    create_table "app_url_rewrite_logs", :force => true do |t|
      t.integer  "app_url_rewrite_id"
      t.datetime "started_at"
      t.datetime "finished_at"
      t.float    "runtime"
      t.text     "results",         :limit => 16777215
      t.datetime "created_at",                                 :null => false
    end

    add_index "app_url_rewrite_logs", ["app_url_rewrite_id"], :name => "app_rewrite_ndx"


    # core rewrites for existing wordpress applications
    AppUrlRewrite.reset_column_information
    AppUrlRewriteLog.reset_column_information
    Application.reset_column_information

    Application.active.wordpress_apps.each do |application|
      if(production_location = application.production_location)
        # staging
        if(staging_location = application.staging_location)
          AppUrlRewrite.create(application_id: application.id,
                               location: AppUrlRewrite::STAGING,
                               search_host: production_location.display_url,
                               replace_host: staging_location.display_url)
        end
        # localdev
        AppUrlRewrite.create(application_id: application.id,
                             location: AppUrlRewrite::LOCALDEV,
                             search_host: production_location.display_url,
                             replace_host: "#{application.name.downcase}.localdev:8888")
      end
    end
  end
end
