Kiwi::Application.routes.draw do
  devise_for :users
  resources :users
  resources :events
  root :to => 'home#index'

end
