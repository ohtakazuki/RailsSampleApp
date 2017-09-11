Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root 'static_pages#home'
  get '/help',    to:'static_pages#help'
  get '/about',   to:'static_pages#about'
  get '/contact', to:'static_pages#contact'
  get '/signup',  to:'users#new'
  # 以下を追加し、new.htmlのpost先をsignup_pathにする。
  # controllerでrender newしているのでテストはGREEN
  post '/signup', to:'users#create'

  # ログイン用
  get '/login',     to:'sessions#new'
  post '/login',    to:'sessions#create'
  delete '/logout', to:'sessions#destroy'

  # これでフル機能のRESTが使えるようになる
  resources :users
  
  # メールで受け取るのでGETのeditのみ
  resources :account_activations, only: [:edit]
  
  # パスワードの再設定用
  resources :password_resets, only: [:new, :create, :edit, :update]
end
