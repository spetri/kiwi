Kiwi::Application.routes.draw do
  resources :events
  root 'home#index'
end
