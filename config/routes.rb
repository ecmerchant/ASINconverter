Rails.application.routes.draw do

  root to: 'items#generate'

  get 'items/generate'
  get 'items', to: 'items#generate'

  post 'items/convert'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
