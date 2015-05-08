class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception 
  helper_method :templates_index_url, :clients_index_url, :new_template_url, :new_client_url


	def templates_index_url
    	return "#{ENV["BLOGS_API"]}?key=#{session[:key]}"
	end

	def clients_index_url
		return "#{ENV["CLIENTS_API"]}?key=#{session[:key]}"
	end 

	def new_template_url
    	return "#{ENV["BLOGS_API"]}new_template/?key=#{session[:key]}"
  	end 

  	def new_client_url
    	return "#{ENV["CLIENTS_API"]}new?key=#{session[:key]}"
  	end


end
