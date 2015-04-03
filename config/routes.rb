Rails.application.routes.draw do
  
  get 'submissions/new'  
  get 'test', :to => 'submissions#test' 
end
