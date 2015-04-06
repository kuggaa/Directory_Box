Rails.application.routes.draw do
  
  get 'search', :to => 'submissions#search_business' 
  get 'localeze', :to => 'submissions#test' 
  get 'send', to: 'submissions#test'

  get "localeze/:id", to: "submissions#localeze"

end
