require 'sidekiq/web'
require 'auth_constraint'

Albatross::Application.routes.draw do
  mount Sidekiq::Web => '/queues', :constraints => AuthConstraint.new

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
      get  :crons
    end

    member do
      get :showlog
    end

  end

  resources :backups, :only => [:index, :show] do
    collection do
      post :log
      post :ping
    end
  end

  match '/engbot/ask' => 'engbot#ask'
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
