
class Webclient


def self.get( url, headers: {}, auth: [] )

  uri = URI.parse( url )
  http = Net::HTTP.new( uri.host, uri.port )

  if uri.instance_of? URI::HTTPS
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Get.new( uri.request_uri )

  ### add (custom) headers if any
  ##  check/todo: is there are more idiomatic way for Net::HTTP ???
  ##   use
  ##     request = Net::HTTP::Get.new( uri.request_uri, headers )
  ##    why? why not?
  ##  instead of e.g.
  ##   request['X-Auth-Token'] = 'xxxxxxx'
  ##   request['User-Agent']   = 'ruby'
  ##   request['Accept']       = '*/*'
  if headers && headers.size > 0
    headers.each do |key,value|
      request[ key ] = value
    end
  end


  if auth.size == 2   ## e.g. ['user', 'password']
    ## always assume basic auth for now
    ##  auth[0]  => user
    ##  auth[1]  => password
    request.basic_auth( auth[0], auth[1] )
    puts "  using basic auth - user: #{auth[0]}, password: ***"
  end


  puts "GET #{uri}..."

  response = http.request( request )

  ## note: return "unified" wrapped response
  Response.new( response )
end  # method self.get


end  # class Webclient
