Dbhero::Engine.routes.draw do
  root to: "dataclips#index"
  resources :dataclips do
    get :drive, on: :collection
  end

  get :one_time_query, to: "one_time_query#index"
end
