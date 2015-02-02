Albatross::Application.routes.draw do

  use_doorkeeper

  resources :deploys, :only => [:show, :index, :create] do
    collection do
      get :production
      get :byapplication
      get :recent
      get :production
      get :fakeit
      post :fakeit
      post :githubnotification
    end

    member do
      put :setcomment
    end
  end

  resources :dumps, :only => [:index, :show] do
    collection do
      get :dumpinfo
      post :do
    end
  end

  resources :apps, only: [:index, :show]
  resources :coders, only: [:index, :show]

  resources :cronmons, only: [:index, :show] do
    collection do
      post :register
      post :log
      post :heartbeat
      get  :servers
      get  :server
    end

    member do
      get :showlog
    end

  end

  match '/logout' => 'auth#end', :as => 'logout'
  match '/auth/:provider/callback' => 'auth#success'
  match '/:controller(/:action(/:id))'

  # webmail example routing
  namespace "webmail" do
    namespace "examples" do
      match "/:action"
    end
  end

  root :to => 'deploys#recent'


end
