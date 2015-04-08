class SubmissionsController < ApplicationController
require "#{Rails.root}/app/helpers/localeze.rb" 


 def submit_to_localeze
   raise params[:select].to_s.inspect
 api_client = LocalezeClient.new 
 returned = api_client.check(@business_to_regester) 
 raise returned.inspect 
 end 



def search_business
end


def account_manager
	@client = get_client_by_id(params[:id])
 	@post_options = { "Check management" => "3722", "Post listing" => "3700" }
end


def test
   require "open-uri"
   name = params[:business_name].to_s
   url = URI.escape("http://clientcloud.herokuapp.com/search?key=593264690503&q=#{name}")
   response = open(url).read
   @search_result= JSON.parse(response)
   render "search_business"

end

private

def get_client_by_id(id)
   require "open-uri"
   url = URI.escape("http://clientcloud.herokuapp.com/retrieve?key=593264690503&id=#{id}&business_detail&contact_detail&social_networking_detail")
   response = open(url).read
   return JSON.parse(response)
end

end







