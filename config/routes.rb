Kiwi::Application.routes.draw do
  devise_for :users, :controllers => {
    :registrations      => "registrations",
    :omniauth_callbacks => "omniauth_callbacks"
  }
  resources :users
  resources :events
  get  '/change_password',        :to => 'passwords#change_password',  :as => 'change_password'
  get '/api/events/startupEvents', :to => 'events#startup_events', :as => 'startup_events'
  root :to => 'home#index'

end
