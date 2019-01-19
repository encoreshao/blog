# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: "/i/admin/auth", path_names: {
    sign_in: :login,
    sign_out: :logout
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :admin, path: "/i/admin" do
    resources :dashboards, only: [:index]
    resources :articles
    resources :users
    resources :tags
    resources :categories
    resources :comments
    resources :site_groups
    resources :site_links

    root "dashboards#index"
  end

  namespace :pages do
    resources :fullpanels, only: [:index], constraints: { format: "html" } do
      collection do
        get :pagepiling
        get :typed
        get :slides
        get :slack_logo
      end
    end
    root "homepages#index"
  end

  resources :articles, only: [] do
    collection do
      get :timeline
      post :comments
      constraints format: :json do
        post :like
        post :dislike
      end
    end
  end

  resources :sites, only: [:index] do
    collection do
      get :author
      get :feedback
      post :feedback
    end
  end

  resources :uploads, only: [] do
    collection do
      post :image
    end
  end

  get "/:year/:month/:day/:permalink" => "articles#show",
      requirements: {
        year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/
      },
      as: :article

  get "category/:category" => "dashboards#index", as: :categories
  get "tag/:tag" => "dashboards#index", as: :tags

  resources :dashboards, only: [:index] do
    collection do
      get :articles
    end
  end

  root "dashboards#index"
end
