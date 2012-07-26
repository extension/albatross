Albatross::Application.routes.draw do
  root :to => 'deploys#index'
  
  resources :deploys, :only => [:show, :index, :create] do
    collection do
      get :production
    end
    
    member do
      put :setcomment
    end
  end
  
  resources :cron_logs, :only => [:show, :index, :create]
  resources :crons, :only => [:show, :index] 
  resources :notifications, :only => [:show, :index, :create, :update] 
  
  match '/logout' => 'auth#end', :as => 'logout'
  match '/auth/:provider/callback' => 'auth#success'
  match '/:controller(/:action(/:id))'

end
