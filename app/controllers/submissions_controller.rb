class SubmissionsController < ApplicationController
require_dependency "#{Rails.root}/app/helpers/localeze.rb" 
  
  helper_method :get_client_by_id2

   def search_business
      @submissions = Submission.all.order(registration_date: :desc)
   end

   

   def account_manager
      response = get_client_by_id(params[:id])
      submission = Submission.find_by(client_id: params[:id])
      submission ||= Submission.new(client_id: params[:id])
      submission.registration_date = Time.now
      submission.save
      send_data response, :type => "csv", :filename => 'localeze.csv'
   end


   def test
      require "open-uri"
      name = params[:business_name].to_s
      url = URI.escape("http://clientcloud.herokuapp.com/search?key=593264690503&q=#{name}")
      response = open(url).read
      @search_result = JSON.parse(response)
      @submissions = Submission.all.order(registration_date: :desc)
      render "search_business"
   end

   
   private

   def get_client_by_id2(id)
      require "open-uri"
      url = URI.escape("http://clientcloud.herokuapp.com/retrieve?key=593264690503&id=#{id}&business_detail&contact_detail&social_networking_detail&operation_detail&address_detail")
      return JSON.parse(open(url).read)
   end


   def get_client_by_id(id)
      require "csv"
      require "open-uri"
      require "time"
      url = URI.escape("http://clientcloud.herokuapp.com/retrieve?key=593264690503&id=#{id}&business_detail&contact_detail&social_networking_detail&operation_detail&address_detail")
      response = open(url).read
      business_data = JSON.parse(response) 
      #raise business_data.inspect  
      primary_phone       = business_data["contact_detail"]["phone"].gsub(/[^\d]/, "")
      mobile_phone        = business_data["contact_detail"]["mobile"].gsub(/[^\d]/, "") 
      toll_free_phone     = business_data["contact_detail"]["toll_free"].gsub(/[^\d]/,"")
      alternate_phone     = business_data["contact_detail"]["alternate"].gsub(/[^\d]/,"")
      hours_of_operation  = get_hours(business_data["operation_detail"]["operation_hours"])
        
      if business_data["business_detail"]["industry"] == "auto"
         primary_category = "AUTOMOBILE - REPAIRS & SERVICES"           
      elsif business_data["business_detail"]["industry"] == "dental"
         primary_category = "DENTISTS"          
      else 
         primary_category = "OTHER"
      end

      primary_category    = business_data["business_detail"]["industry"]
      empty_string        = ""
   
      localeze_formatted  = [business_data["business_detail"]["business_name"],
                            empty_string, 
                            business_data["address_detail"]["address_line_1"],
                            business_data["address_detail"]["address_line_2"],
                            business_data["address_detail"]["city"],
                            business_data["address_detail"]["state"],
                            business_data["address_detail"]["zip"],
                            primary_phone,
                            primary_category,
                            business_data["business_detail"]["website"],
                            business_data["business_detail"]["logo_url"], 
                            business_data["contact_detail"]["email"],
                            toll_free_phone,
                            business_data["contact_detail"]["fax"],
                            mobile_phone, 
                            alternate_phone,
                            hours_of_operation,
                            business_data["operation_detail"]["payment_methods"].map(&:upcase).join(","),
                            business_data["operation_detail"]["spoken_languages"].join(","),
                            business_data["business_detail"]["year_established"],
                            empty_string, empty_string, empty_string,empty_string, 
                            business_data["business_detail"]["keywords"].join(","),
                            business_data["social_networking_detail"]["facebook_url"],
                            business_data["social_networking_detail"]["linkedin_url"],
                            business_data["social_networking_detail"]["twitter_url"],
                            business_data["social_networking_detail"]["google_plus_url"],
                            business_data["social_networking_detail"]["yelp_url"],
                            business_data["social_networking_detail"]["foursquare_url"]]
    
      localeze_csv = localeze_formatted.to_csv
      # raise localeze_csv.inspect
      return localeze_csv

   end

   def get_hours(business_hours)
       associated_days_array = ["NN", "MM", "TT", "WW", "RR", "FF", "SS"]
       formatted_hours_array = business_hours.each_with_index.map do |e, i| 
       next e if e.blank?  
       dd = associated_days_array[i]
       military_hours_array = e.split(" - ").map { |x| Time.parse(x).strftime("%H%M") }
       hours_for_day_string = "#{dd}#{military_hours_array.join}H"
   end
      return formatted_hours_array.join
   end

end 




