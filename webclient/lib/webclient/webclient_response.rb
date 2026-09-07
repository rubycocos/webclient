
class Webclient
  # wrap Net::HTTP::Response  or
  #    maybe HTTPX or such in the future

  ## check - rename to HttpResponse?
  ##      and use  HttpErrorResponse or such - why? why not?
  class Response
    def initialize( response )
      @response = response
    end

    ## todo - find a better name for underlying object - instead of raw use ??
    ##   note - raw used by python requests too
    ##            use for streaming and such - why? why not?
    def raw() @response; end


    ###############
    ##  response status methods

    def status
      @status ||= Status.new( @response.code, message: @response.message )
    end

    ## add  "flat" shortcuts - keep - why? why not?
    def status_code()  status.to_i; end
    def ok?()          status.ok?; end
    def nok?()         status.nok?; end



    ###
    ## keep http_version on Response - why? why not?
    ##    only really 1.0 and 1.1
    ##      check if value is a string?
    def version() @response.http_version; end
    alias_method :http_version, :version   ## add/keep longer alias too - why? why not?





    ###
    #  note - add a writeable  encoding_user attribute
    ##            on default (if not set by user) returns nil
    def _encoding_user=( value ) @_encoding_user = value; end
    def _encoding_user()  defined?( @_encoding_user )  ?  @_encoding_user : nil;  end

    ## cache (returned) decoded text - why? why not?
    def text( encoding: _encoding_user )
        @text ||= _decode_text( encoding: encoding )
    end

    ## convenience helper; returns parsed json data; note: always assume utf-8 (text) encoding
    ##   cache returned (parsed) json value - why? why not?
    ##   add :symbolize_keys option - why? why not?
    def json
        @json ||= JSON.parse( text )
    end



    ##  always use t raw binary data
    ##  and always use  @response.body.b
    ##         or body.b  (binary ascii-7bit) string/buffer here !!!!
    ##

    def body() @response.body.b; end
    alias_method :blob, :body



    ################
    # nested class Response::Headers
    class Headers
      def initialize( response )
        @response = response
      end
      def each( &blk )
        @response.each_header do |key, value|  # iterate all response headers
          blk.call( key, value )
        end
      end
    end    # nested class Response::Headers

    def headers
       @headers ||= Headers.new( @response )
    end




    ## add some predefined/built-in header(s) convenience shortcuts
    ## check: change to headers['content-type'] or such - why? why not?
    def content_type()    @response.content_type; end
    def content_length()  @response.content_length; end

    ###
    ##  note - content_type might return nil, thus, use to_s (gets converted to "")
    def image_jpg?()   content_type.to_s.match?( %r{image/jpeg}i );   end
    def image_png?()   content_type.to_s.match?( %r{image/png}i );    end
    def image_gif?()   content_type.to_s.match?( %r{image/gif}i );    end

    alias_method :image_jpeg?, :image_jpg?
    alias_method :jpeg?, :image_jpg?
    alias_method :jpg?, :image_jpg?
    alias_method :png?, :image_png?
    alias_method :gif?, :image_gif?

end ##  class Response
end  # class Webclient
