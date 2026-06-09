Rails.application.routes.draw do
  get '/unread_issues', to: 'unread_issues#index'
end
