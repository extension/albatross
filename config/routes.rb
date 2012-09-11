Albatross::Application.routes.draw do
  root :to => 'deploys#index'
  
  resources :deploys, :only => [:show, :index, :create] do
    collection do
      get :production
      get :fakeit
      post :fakeit
    end
    
    member do
      put :setcomment
    end
  end
  
  resources :notifications, :only => [:show, :index, :create, :update] 
  
  match '/logout' => 'auth#end', :as => 'logout'
  match '/auth/:provider/callback' => 'auth#success'
  match '/:controller(/:action(/:id))'

end
