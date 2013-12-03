Kiwi::Application.routes.draw do
  devise_for :users, :controllers => {
    :registrations      => "registrations",
    :omniauth_callbacks => "omniauth_callbacks"
  }
  resources :users
  resources :events
  root :to => 'home#index'

end
