Kiwi::Application.routes.draw do
  devise_for :users, :controllers => {
    :registrations      => "registrations",
    :omniauth_callbacks => "omniauth_callbacks"
  }
  resources :users
  resources :events
  get  '/change_password',        :to => 'passwords#change_password',  :as => 'change_password'
  root :to => 'home#index'

end
