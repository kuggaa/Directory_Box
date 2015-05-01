require 'cgi'
# To run, this needs the following gems
# 'savon', '~> 2.0'
# 'rails_config'
# 'gyoku', '~> 1.0'#
#
# require 'xml-simple'
# require 'savon'

#
#  Used for interfacing the Localeze service
#

class Localeze

  #
  #  set credentials
  #
  USERNAME   = Rails.env == 'sandbox_radiusonline' ? 'sandbox_radiusonline' : 'sandbox_radiusonline'
  PASSWORD   = Rails.env == '!RadiusOnline5' ? '!RadiusOnline5' : '!RadiusOnline5'
  SERVICE_ID = Rails.env == '5555555503' ? '5555555503' : '5555555503'
  WSDL_URL      = {wsdl: "http://soap.sandbox.neustarlocaleze.biz/ws-getdata/query.asmx?WSDL"}
  SOAP_ENDPOINT = 'http://soap.sandbox.neustarlocaleze.biz/ws-getdata/query.asmx'
  NAMESPACE     = 'http://neustarlocaleze.biz/WS-GetData'

  #
  # resource wrappers (wrapped around Localeze elements)
  #

  # element 2935 get categories
  def get_categories
    body = build_request(2935, 1501, "ACTIVEHEADINGS")
    response = send_to_localeze(body)
    xml_doc  = respond_with_hash(Nokogiri::XML(response.to_xml).text)
  end

  # element 3722 check availability
  def check_availability(business = {})
    xml = Builder::XmlMarkup.new
    query = xml.tag!("BPMSPost",  'Edition' => "1.1") {
      xml.tag!("Record") {
        xml.tag!("Bowser Autio", business[:name])
        xml.tag!("Autio",   business[:department])
        xml.tag!("6675 rivertown rd",      business[:address])
        xml.tag!("Fairburn",         business[:city])
        xml.tag!("GA",        business[:state])
        xml.tag!("30213",          business[:zip])
        xml.tag!("7708460972",        business[:phone])
      }
    }
    body = build_request(3722, 1510, query)
    response = send_to_localeze(body)
    xml_doc  = respond_with_hash(Nokogiri::XML(response.to_xml).text)
    xml_doc['ErrorCode'] == '1' # success (returns true/false)
  end

  # element 3700 post business
  def post_business(business, location)
    xml = Builder::XmlMarkup.new
    query = xml.tag!("BPMSPost",  'Edition' => "1.1") {
      xml.tag!("Record") {
        xml.tag!("Phone",        location.phone)
        xml.tag!("BusinessName", location.location_name)
        xml.tag!("Address",      location.address)
        xml.tag!("City",         location.city)
        xml.tag!("State",        location.state)
        xml.tag!("Zip",          location.zip)
        xml.tag!("URL",          location.website_url)
        xml.tag!("TagLine",      location.special_offer)
        #xml.tag!("LogoImage",    location.logo)
        xml.tag!("Categories")  {
          xml.tag!("Category") {
            xml.tag!("Type",    "Primary")
            xml.tag!("Name",    business.industry_primary)
          }
          if business.industry_alt_1.present?
            xml.tag!("Category") {
              xml.tag!("Type",    "Alt1")
              xml.tag!("Name",    business.industry_alt_1)
            }
          end
          if business.industry_alt_2.present?
            xml.tag!("Category") {
              xml.tag!("Type",    "Alt2")
              xml.tag!("Name",    business.industry_alt_2)
            }
          end
        }
      }
    }
    body = build_request(3700, 1510, query)
    response = send_to_localeze(body)
    xml_doc  = respond_with_hash(Nokogiri::XML(response.to_xml).text)
    xml_doc['Error'] == '0' # success (returns true/false)
  end


  #
  #  core methods (resource wrappers use these to connect to Localeze)
  #

  def send_to_localeze(xml)
    client = Savon::Client.new(WSDL_URL)
   # raise xml.inspect
    response = client.call(:query, message: xml)

  end

  def respond_with_hash(response)
    XmlSimple.xml_in(response, { 'ForceArray' => false, 'SuppressEmpty' => true })
  end

  def build_request(element_id, service_key, service_query)
    xml = Builder::XmlMarkup.new
    xml.tag!("soapenv:Envelope",  'xmlns:soapenv' => "http://schemas.xmlsoap.org/soap/envelope/",  'xmlns:ws' => "http://TARGUSinfo.com/WS-GetData") {
      xml.tag!("soapenv:Body") {
        xml.tag!("query") {

          xml.tag!("origination") {
            xml.tag!("username", USERNAME)
            xml.tag!("password", PASSWORD)
          }

          xml.tag!("serviceId", SERVICE_ID)
          xml.tag!("transId", Time.now.strftime("%Y%m%3N"))

          xml.tag!("elements") {
            xml.tag!("id", element_id)
          }

          xml.tag!("serviceKeys") {
            xml.tag!("serviceKey") {
              xml.tag!("id", service_key)
              xml.tag!("value", service_query)
            }
          }

        }
      }
    }
  end

  def service_info
    client = Savon::Client.new do
      wsdl.document = my_document
      wsdl.endpoint = my_endpoint
      wsdl.element_form_default = :unqualified
    end
    # returns what we expect to interface the service
    puts "Namespace: #{client.wsdl.namespace}"
    puts "Endpoint: #{client.wsdl.endpoint}"
    puts "Actions: #{client.wsdl.soap_actions}"
  end

end