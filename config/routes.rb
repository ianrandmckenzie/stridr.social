Rails.application.routes.draw do
  get 'home/index'

  get 'accounts/customize'
  get 'accounts/table'
  get 'user/loading_card'
  get 'errors/not_found'
  get 'errors/internal_server_error'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "registrations" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  devise_scope :user do
    get 'users/preferences' => 'registrations#preferences', as: :preferences
    put 'filter_youtube', to: 'registrations#filter_youtube'
  end

  root 'user#feed'
  get 'user/loading' => 'user#loading', as: :loading
  get 'user/:id' => 'user#show', as: :profile
  get 'user/:id/recommendations' => 'home#index', as: :recommendations
  get 'friends' => 'user#friends', as: :friends
  get 'match/:id' => 'user#match', as: :match
  get 'difference/:id' => 'user#difference', as: :difference

  resources :social_page, only: [ :index, :show ]

  # Rails expects the error pages to be served from /<error code>.
  # Adding these simple routes in config/routes.rb connects those
  # requests to the appropriate actions of the errors controller.
  # Using match ... :via => :all allows the error pages to be displayed
  #  for any type of request (GET, POST, PUT, etc.).
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  scope '/api' do
    scope '/v1' do
      scope '/social_pages' do
        get '/' => 'api_social_pages#index'
        scope '/default_feed' do
          get '/' => 'api_social_pages#default'
        end
        scope '/search' do
          get '/' => 'api_social_pages#search'
        end
        scope '/:id' do
          get '/' => 'api_social_pages#show'
          scope '/suggestions' do
            get '/' => 'api_social_pages#suggestions'
          end
        end
      end
      scope '/users' do
        scope '/:id' do
          get '/' => 'api_users#show'
          scope '/friends' do
            get '/' => 'api_users#friends'
          end
          scope '/social_pages_list' do
            get '/' => 'api_users#social_pages_list'
          end
          scope '/recommendations' do
            get '/' => 'api_users#recommendations'
          end
        end
      end
    end
  end

end
