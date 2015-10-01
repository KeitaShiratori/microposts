Rails.application.routes.draw do
  root to: 'static_pages#home'
  get 'signup', to: 'users#new'
  get    'login'           => 'sessions#new'
  post   'login'           => 'sessions#create'
  delete 'logout'          => 'sessions#destroy'
  get 'feed'               => 'users#feed'
  get 'microposts'         => 'users#microposts'
  get 'followers'          => 'users#followers'
  get 'following'          => 'users#following'
  get 'search_users'       => 'users#search_users'
  get 'search_microposts'  => 'users#search_microposts'

  resources :users
  resources :sessions,      only: [:new, :create, :destroy]
  resources :microposts do
    member { post :vote }
  end
  resources :relationships, only: [      :create, :destroy]
  resources :retweets,      only: [      :create, :destroy]
end