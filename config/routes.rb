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
    end

    member do
      put :setcomment
    end
  end

  resources :cron_logs, :only => [:show, :create]
  resources :crons, :only => [:show, :index]
  resources :notifications, :only => [:show, :index, :create, :update]

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
