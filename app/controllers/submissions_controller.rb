class SubmissionsController < ApplicationController
require "#{Rails.root}/app/helpers/localeze.rb" 

def localeze
 

 api_client = LocalezeClient.new 
 returned = api_client.check(@business_to_regester) 

raise returned.inspect 
end 



def search_business
 
end

def test
   require "open-uri"
   name = params[:business_name].to_s
   url = URI.escape("http://clientcloud.herokuapp.com/search?key=593264690503&q=#{name}")
   response = open(url).read
   @search_result= JSON.parse(response)
   render "search_business"

end

end

