Rails.application.routes.draw do
  use_doorkeeper_openid_connect
  use_doorkeeper
  devise_for :users, controllers: { sessions: 'user/sessions',
                                    passwords: 'user/passwords',
                                    confirmations: 'user/confirmations',
                                    unlocks: 'user/unlocks',
                                    registrations: 'user/registrations' }
  resources :vendors, only: :index
  get '/me' => 'home#me'
  get '/profiles' => 'home#profiles'
  root to: 'home#index'
end
