Rails.application.routes.draw do
  use_doorkeeper
  use_doorkeeper_openid_connect
  devise_for :users, controllers: { sessions: 'user/sessions',
                                    passwords: 'user/passwords',
                                    confirmations: 'user/confirmations',
                                    unlocks: 'user/unlocks',
                                    registrations: 'user/registrations' }
  resources :vendors, only: :index

  get '/me' => 'doorkeeper#me'
  get '/profiles' => 'doorkeeper#profiles'
  # To make turbolink still works in client app
  match '/oauth/authorize' => 'doorkeeper#options_authorize', via: :options

  root to: 'home#index'
end
