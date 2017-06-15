Rails.application.routes.draw do
  devise_for :users, path: '/i/admin/auth', path_names: {
    sign_in: :login,
    sign_out: :logout
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :admin, path: '/i/admin' do
    resources :dashboards, only: [:index]
    resources :articles
    resources :users
    resources :tags
    resources :categories
    resources :comments

    root 'dashboards#index'
  end

  get "/:year/:month/:day/:permalink" => "dashboards#show",
      requirements: {
        year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/
        },
        as: :article

  root 'dashboards#index'
end
