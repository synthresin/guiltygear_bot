Rails.application.routes.draw do
   root to: 'welcome#index'
  post '/kimguilty', to: 'kimguilty#show'
end
