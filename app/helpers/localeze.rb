require 'cgi'
# To run, this needs the following gems
# 'savon', '~> 2.0'
# 'rails_config'
# 'gyoku', '~> 1.0'#
#
class LocalezeClient
  def initialize
     @client = Savon.client(wsdl: Settings.localeze_wsdl, namespace: Settings.localeze_wsdl, pretty_print_xml: true)
  end

  # Check that a supplied listing is available to claim.
  def check(listing)
    value = record_to_xml(listing, true)
    raise message(:add, value, :check).inspect
    query = @client.call(:query, message: message(:add, value, :check))
     # rescue Savon::SOAPFault => error
     # raise error.http.inspect
    result = get_deep_value(query)
    check_successful?(result['ErrorCode']) ? true : result['ErrorMessage']
  end

  # Create the supplied listing.
  def create(listing)
    value = record_to_xml(listing, true)
    query = @client.call(:query, message: message(:add, value, :create))
    result = get_deep_value(query)
    status = create_successful?(result)
    handle_status(status)
  end

  # Cache the categories
  def categories
    @_categories ||= categories!  # Memoizing
  end

  private
  # Cached methods
  # make a call to localeze to get a list of all the categories available
  def categories!
    query = @client.call(:query, message: message(:query, 'ACTIVEHEADINGS', :category))  
    headings = get_heading(query)
    headings['ActiveHeadings']['Heading']
  end

  # Not sure why, but Localeze returns either an ErrorMessage or a Validator with a Resolution if there's an error.
  # This will get the error code regardless of where it is in one of these locations
  def get_errors(result)
    if result.has_key?('ErrorMessage')
        return result['ErrorMessage']
    elsif result.has_key?('Validators')
        return result['Validators']['Resolution']
    end
  end

  # The value that localeze gives us is very deep, this method
  # cleans that up a little in the implementation depending on the element
  def get_deep_value(query)
    Hash.from_xml(query.to_hash[:query_response][:response][:result][:element][:value].to_s)['Response']
  end

  # This is a helper method to generate the giant dictionary you send as a message.
  # Rather than needing to supply this dictionary every time, all you need to supply is the Action Key,
  # the value to send, and the ElementId
  def message(key, value, element)

    # xml_string_front= "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>
    #                    <query xmlns=\"http://TARGUSinfo.com/WS-GetData\">"
    # xml_string_back = "</query></soap:Body></soap:Envelope>"
    #   thisHash = {
    #     origination: {
    #       username: Settings.localeze_username,
    #       password: Settings.localeze_password
    #     },
    #     serviceId: Settings.localeze_serviceid,
    #     transId: 1,
    #     elements: {
    #       id: Settings.localeze_ids[element]
    #     },
    #     serviceKeys: {
    #       serviceKey: {
    #         id: Settings.localeze_ids[key],
    #         value: value}
    #       }
    #    }
    # xml_final_string = xml_string_front + thisHash.to_xml + xml_string_back

    xml_string = "
      <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">
        <soap:Body>
          <query xmlns=\"http://TARGUSinfo.com/WS-GetData\">
            <origination>
              <username>sandbox_radiusonline</username>
              <password>!RadiusOnline5</password>
            </origination>
            <serviceId>5555555503</serviceId>
            <transId>1</transId>
            <elements>
              <id>3722</id>
            </elements>
            <serviceKeys>
              <serviceKey>
                <id>1510</id>
                <#{value}>&lt;BPMSPost Edition=\"1.1\"&gt;&lt;Record&gt;&lt;Phone&gt;7708460972&lt;/Phone&gt;&lt;BusinessName&gt;Matt Yeager is Awesome&lt;/BusinessName&gt;&lt;Zip&gt;30213&lt;/Zip&gt;&lt;Categories&gt;&lt;Category&gt;&lt;Name&gt;Auto&lt;/Name&gt;&lt;Type&gt;PRIMARY&lt;/Type&gt;&lt;/Category&gt;&lt;/Categories&gt;&lt;/Record&gt;&lt;/BPMSPost&gt;</value>
              </serviceKey>
            </serviceKeys>
          </query>
        </soap:Body>
      </soap:Envelope>
    "
    # return xml with whitespace (other than spaces) removed
    return xml_string.gsub(/[\t\n]/, "").strip
  end

  # This will wrap a record hash into the xml format required by localeze, also escape if needed.
  # The reason it doesn't just use to_xml, is because we needed the "Edition" attribute.
  def record_to_xml(record, escape = false)
    bmps = {'BPMSPost' => {'Record' => record },  :attributes! => { 'BPMSPost' => { 'Edition' => '1.1' }}}
    Gyoku.xml(bmps, {:key_converter => :none})
  end

  # Check that the error codes returned are Success codes.
  def check_successful? code
    Settings[:localeze_check_success].include? code
  end

  def create_successful? result
     if Settings[:localeze_create_success].include? result['ErrorCode']
        if result['ErrorMessage']
            return [passes: false, message: result['ErrorMessage']]
        elsif result['Validators'].is_a?(Array)
            return [passes: true, message: result['Validators'].map{|v| v['Resolution']} * "\n"]
        elsif result['Validators']
            return [passes: true, message: result['Validators']['Resolution']]
        end
     else
       return true
     end
  end

  def handle_status(status)
    if status.is_a?(Hash)
        if status[:passes]
            puts "Was submitted, but needs validation on site: #{status[:message]}"
        else
            puts "Was not submitted, Please fix: #{status[:message]}"
        end
    else
        puts "Successful"
    end
  end
end