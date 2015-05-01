Rails.application.routes.draw do
  root to: 'submissions#search_business' 
  get 'localeze',  to: 'submissions#test' 
  post 'send',     to: 'submissions#test'
  get 'manage/:id',to: 'submissions#account_manager'
end
