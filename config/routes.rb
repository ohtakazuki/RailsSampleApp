Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',    to:'static_pages#help'
  get '/about',   to:'static_pages#about'
  get '/contact', to:'static_pages#contact'
  get '/signup',  to:'users#new'
  # 以下を追加し、new.htmlのpost先をsignup_pathにする。
  # controllerでrender newしているのでテストはGREEN
  post '/signup', to:'users#create'
  # これでフル機能のRESTが使えるようになる
  resources :users
end
