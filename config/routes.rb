Rails.application.routes.draw do
  use_doorkeeper
  use_doorkeeper_openid_connect
  resources :oauth2_applications, only: %i[update create]

  get '/saml/auth' => 'saml_idp#create'
  get '/saml/metadata' => 'saml_idp#show'
  post '/saml/auth' => 'saml_idp#create'
  match '/saml/logout' => 'saml_idp#logout', via: [:get]
  match '/saml/logout' => 'saml_idp#logout_response', via: [:post]

  get '/homeland/sso' => 'homeland_sso#sso'

  get '/install' => 'install#index'
  get '/install/step1' => 'install#step1'
  get '/install/step2' => 'install#step2'
  get '/install/step3' => 'install#step3'
  get '/install/step4' => 'install#step4'
  post '/install/step1' => 'install#save_step1'
  post '/install/step2' => 'install#save_step2'
  post '/install/step3' => 'install#save_step3'
  post '/install/step4' => 'install#save_step4'

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

  resources :duplicate_employees, only: %i[show index update] do
    collection do
      get :report
    end
  end

  resource :setting, only: :update do
    member do
      get :profile
    end
  end
  resources :departments, only: %i[index edit update] do
    collection do
      get :data
    end
  end
  resources :positions, only: %i[index edit update]

  get '/me' => 'doorkeeper#me'
  get '/profiles' => 'doorkeeper#profiles'

  resources :jwts, only: %i[index create destroy] do
    collection do
      delete :clean_expired_jwts
    end
  end

  namespace :api do
    match 'me' => 'application#user_info', via: :options
  end

  # To make turbolink still works in client app
  match '/oauth/authorize' => 'doorkeeper#options_authorize', via: :options

  root to: 'home#index'
end
