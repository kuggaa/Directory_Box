class SubmissionsController < ApplicationController
require "#{Rails.root}/app/helpers/localeze.rb" 
def test
@business_to_regester = {business_name: "Bowser Automotive",
city: "Butler", state: "PA",postal_code: "16001", primary_phone: "7244822515",
category: "AUTOMOBILE", operation_hours: "MF08001700HSS09001200H",keywords: "Air
Conditioning Service,Air Filter Replacement,Auto Repair Shop,Belt and Hose
Replacement,Brake Service,CV Axles,Chassis Lube,Complete Diagnostic
Services,Computer Diagnostic Testing,Cooling System Flush,Diesel Service and
Repair,Electrical,Exhaust System,Fuel Injection Service,Full Brake,Oil Change
Service,Mechanic,Mufflers,Power Steering,Radiator Coolant Flush,Replace
Lights,Suspension,Suspension and Shock Repair,Tire Rotation,Tire Sales &
Service,Transmission Flush,Transmission Service,Vehicle Fluids,Vehicle
Preventative Maintenance,Wheel Alignment,Wiper Blades" }


 api_client = LocalezeClient.new 
 returned = api_client.check(@business_to_regester) 

raise returned.inspect 
end 




def new
end


end

