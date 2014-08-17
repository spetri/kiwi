Kiwi::Application.routes.draw do
  devise_for :users, :controllers => {
    :registrations      => "registrations",
    :omniauth_callbacks => "omniauth_callbacks"
  }
  resources :users
  resources :events, :except => [:new]
  resources :comments
  resources :reminders


  get '/about', :to => 'static#about', :as => 'about'
  get '/faq', :to => 'static#faq', :as => 'faq'
  get '/termsofservice', :to => 'static#termsofservice', :as => 'termsofservice'

  get '/change_password',        :to => 'passwords#change_password',  :as => 'change_password'
  get '/api/events/startupEvents',   :to => 'events#startup_events', :as => 'startup_events'
  get '/api/events/eventsAfterDate', :to => 'events#events_after_date', :as => 'events_after_date'
  get '/api/events/eventsByDate', :to => 'events#events_by_date', :as => 'events_by_date'
  get '/api/events/:id/comments', :to => 'events#comments', :as => 'events_comments'
  get '*path', :to => 'home#index', :as => 'subkasts'
  root :to => 'home#index'
end
