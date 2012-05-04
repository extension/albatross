Albatross::Application.routes.draw do
  root :to => 'deploys#index'
  
  resources :deploys, :only => [:show, :index, :create] do
    collection do
      get :production
    end
  end
  
  match '/logout' => 'auth#end', :as => 'logout'
  match '/auth/:provider/callback' => 'auth#success'
  match '/:controller(/:action(/:id))'

end
