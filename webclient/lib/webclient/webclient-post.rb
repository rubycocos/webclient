
class Webclient



##
## todo/check
##   maybe add a
###    self.post_form( url, form/params, **kwargs) - why? why not?
###

def self.post( url, headers: {},
                    auth: [],
                    body: nil,
                    form: nil,
                    json: nil   ## json - convenience shortcut (for body & encoding)
              )

  uri = URI.parse( url )
  http = Net::HTTP.new( uri.host, uri.port )

  if uri.instance_of? URI::HTTPS
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Post.new( uri.request_uri )

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


  if body
     request.body = body.to_s
  end

  if form
     ## fix-fix-fix: urlencode key/values!!!!!

     ###
     ## maybe use ??
     ##  uri = URI "http://localhost:4567/greet"
     ##    params = { :name => 'Peter' }
     ##    uri.query = URI.encode_www_form params

     form_urlencoded = form.map do |k,v|
                                     "#{k}=#{v}"
                                 end.join( '&' )

     request.body = form_urlencoded

    request['Content-Type'] = 'application/x-www-form-urlencoded'
  end

  if json
     # note: the body needs to be a JSON string - use pretty generate and NOT "compact" style - why? why not?
     request.body = JSON.pretty_generate( json )

     ## move (auto-set) header content-type up (before custom headers) - why? why not?
     request['Content-Type'] = 'application/json'
  end


  puts "POST #{uri}..."

  response = http.request( request )

  ## note: return "unified" wrapped response
  Response.new( response )
end  # method self.post


end # class Webclient