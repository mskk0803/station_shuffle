Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # 2025-03-10 postのルーティング定義
  resources :posts, only: %i[index new create destroy] do
    # collection do
    #   get :likes
    # end
  end

  # 2025-03-15 destinationのルーティング定義
  resources :destinations, only: %i[new] do
    collection do
      post :get_location
    end
  end

  # 2025-03-19 checkinのルーティング作成
  resources :checkins, only: %i[create]

  # 2025-03-19 likeのルーティング定義
  resources :likes, only: %i[create destroy]

  # 2025-04-11 mypageのルーティング定義
  resources :mypages, only: %i[show] do
    get :posts
    get :likes
    get :checkins
  end

  # 2025-03-09 devise導入。各画面表示用のルーティング定義。
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
end
