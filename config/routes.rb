Rails.application.routes.draw do
  root "static_pages#home"
  # get 'static_pages/home' # Not needed since root has now the path to home action
  get '/help', to: 'static_pages#help' # this gives a shorter path than: get 'static_pages/help'
  get '/helf', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'

  delete '/logout', to: 'sessions#destroy'

  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
