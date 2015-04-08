Rails.application.routes.draw do
  
  get 'search', :to => 'submissions#search_business' 
  get 'localeze', :to => 'submissions#test' 
  post 'send', :to => 'submissions#test'
  post "submit", to: 'submissions#submit_to_localeze'
  get "manage/:id", to: "submissions#account_manager"

end
