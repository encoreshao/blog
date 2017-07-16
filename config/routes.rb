Rails.application.routes.draw do
  devise_for :users, path: '/i/admin/auth', path_names: {
    sign_in: :login,
    sign_out: :logout
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :admin, path: '/i/admin' do
    resources :dashboards, only: [:index]
    resources :articles do
      collection do
        get :contenteditable
      end
    end
    resources :users
    resources :tags
    resources :categories
    resources :comments

    root 'dashboards#index'
  end

  resources :articles, only: [] do
    collection do
      post :comment
      constraints format: :json do
        post :like
        post :dislike
      end
    end
  end

  get "/:year/:month/:day/:permalink" => "articles#show",
      requirements: {
        year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/
      },
      as: :article

  get "category/:category" => "dashboards#index", as: :categories
  get "tag/:tag" => "dashboards#index", as: :tags

  root 'dashboards#index'
end
