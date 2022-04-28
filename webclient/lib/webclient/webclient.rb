
class Webclient

  class Response   # nested class - wrap Net::HTTP::Response
    def initialize( response )
      @response = response
    end
    def raw() @response; end


    ## todo/check: rename encoding to html/http-like charset - why? why not?
    def text( encoding: 'UTF-8' )
      # note: Net::HTTP will NOT set encoding UTF-8 etc.
      # will be set to ASCII-8BIT == BINARY == Encoding Unknown; Raw Bytes Here
      # thus, set/force encoding to utf-8
      text = @response.body.to_s
      if encoding.downcase == 'utf-8'
         text = text.force_encoding( Encoding::UTF_8 )
      else
    ## [debug] GET=http://www.football-data.co.uk/mmz4281/0405/SC0.csv
    ##    Encoding::UndefinedConversionError: "\xA0" from ASCII-8BIT to UTF-8
    ##     note:  0xA0 (160) is NBSP (non-breaking space) in Windows-1252

    ## note: assume windows encoding (for football-data.uk)
    ##   use "Windows-1252" for input and convert to utf-8
    ##
    ##    see https://www.justinweiss.com/articles/3-steps-to-fix-encoding-problems-in-ruby/
    ##    see https://en.wikipedia.org/wiki/Windows-1252
    ## txt = txt.force_encoding( 'Windows-1252' )
    ## txt = txt.encode( 'UTF-8' )
    ##   Encoding::UTF_8 => 'UTF-8'
        puts " [debug] converting response.text encoding from >#{encoding}< to >UTF-8<"

        text = text.force_encoding( encoding )
        text = text.encode( Encoding::UTF_8 )
      end

      text
    end

    ## convenience helper; returns parsed json data; note: always assume utf-8 (text) encoding
    def json() JSON.parse( text ); end


    def body() @response.body.to_s; end
    alias_method :blob, :body



    class Headers # nested (nested) class
      def initialize( response )
        @response = response
      end
      def each( &blk )
        @response.each_header do |key, value|  # Iterate all response headers
          blk.call( key, value )
        end
      end
    end
    def headers() @headers ||= Headers.new( @response ); end


    ## add some predefined/built-in header(s) convenience shortcuts
    def content_type
      ## check: change to headers['content-type'] or such - why? why not?
      @response.content_type
    end
    def content_length
      @response.content_length
    end

    def image_jpg?
      content_type =~ %r{image/jpeg}i
    end
    def image_png?
      content_type =~ %r{image/png}i
    end
    def image_gif?
      content_type =~ %r{image/gif}i
    end

    alias_method :image_jpeg?, :image_jpg?
    alias_method :jpeg?, :image_jpg?
    alias_method :jpg?, :image_jpg?
    alias_method :png?, :image_png?
    alias_method :gif?, :image_gif?



    class Status  # nested (nested) class
      def initialize( response )
        @response = response
      end
      def code() @response.code.to_i; end
      def ok?()  code == 200; end
      def nok?() code != 200; end
      def message() @response.message; end
    end
    def status() @status ||= Status.new( @response ); end
  end # (nested) class Response


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


def self.post( url, headers: {},
                    body: nil,
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

  if body
     request.body = body.to_s
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


end  # class Webclient

