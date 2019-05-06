Rails.application.routes.draw do
  use_doorkeeper
  use_doorkeeper_openid_connect
  resources :oauth2_applications, only: %i[update create]

  get '/saml/auth' => 'saml_idp#create'
  get '/saml/metadata' => 'saml_idp#show'
  post '/saml/auth' => 'saml_idp#create'
  match '/saml/logout' => 'saml_idp#logout', via: [:get]
  match '/saml/logout' => 'saml_idp#logout_response', via: [:post]

  resource :wechat, only: [:show, :create]

  devise_for :users, controllers: { sessions: 'user/sessions',
                                    passwords: 'user/passwords',
                                    confirmations: 'user/confirmations',
                                    unlocks: 'user/unlocks',
                                    registrations: 'user/registrations' }
  resources :employees, only: %i[index edit update show] do
    member do
      get :sign_in_histories
    end
    collection do
      get :report
    end
  end
  resource :setting, only: :update do
    member do
      get :profile
    end
  end
  resource :departments, only: [] do
    collection do
      get :data
    end
  end

  get '/me' => 'doorkeeper#me'
  get '/profiles' => 'doorkeeper#profiles'
  # To make turbolink still works in client app
  match '/oauth/authorize' => 'doorkeeper#options_authorize', via: :options

  root to: 'home#index'
end
