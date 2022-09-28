Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace "api", module: "api" do
    resources :users, only: [:create]
    post '/authentication/login', to: 'authentication#create'
    get '/foo', to: 'foo#show'
  end
end
