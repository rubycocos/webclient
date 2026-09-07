
class Webclient

  # wrap Net::HTTP::Response
  class Response
    class Status  # nested class  Response::Status
      ### fix-fix-fix
      ##  maybe fold back
      ##      into response.status | status_code
      ##           response.status_message | status_msg
      ##         keep it simple?
      ##
      ##   keep status.ok?    =>  response.ok?
      ##   keep status.nok?   =>  response.nok?

      def initialize( response )
        @response = response
      end


      ## note - upstream Net::HTTP::Response::code is a string e.g. "200"!!!
      ##             convert to integer number
      def code() @response.code.to_i(10); end
      def ok?()  code == 200; end
      def nok?() code != 200; end

      def message() @response.message; end
      alias_method :msg, :message   ## add/keep shorter alias too - why? why not?
    end  # (nested) class Status

    def status()  @status ||= Status.new( @response ); end




    def initialize( response )
      @response = response
    end

    ## todo - find a better name for underlying object - instead of raw use ??
    ##   note - raw used by python requests too
    ##            use for streaming and such - why? why not?
    def raw() @response; end

    ###
    ## keep http_version on Response - why? why not?
    ##    only really 1.0 and 1.1
    ##      check if value is a string?
    def version() @response.http_version; end
    alias_method :http_version, :version   ## add/keep longer alias too - why? why not?



    ## convenience helper; returns parsed json data; note: always assume utf-8 (text) encoding
    ##   cache returned (parsed) json value - why? why not?
    def json() @json ||= JSON.parse( text ); end


    ###
    ###  fix-fix-fix    fix-fix-fix
    ##      avoid  text.dup
    ##
    ##  and always use  @response.body.to_s.b
    ##         or body.b  (binary ascii-7bit) string/buffer here !!!!
    ##
    ##  # 1. Get raw binary data so Ruby doesn't guess the encoding yet
    ##  raw_body = response.body.b
    ##
    def body() @response.body.b; end
    alias_method :blob, :body




    class Headers # nested class Response::Headers
      def initialize( response )
        @response = response
      end
      def each( &blk )
        @response.each_header do |key, value|  # iterate all response headers
          blk.call( key, value )
        end
      end
    end   # nested class Response::Headers
    def headers() @headers ||= Headers.new( @response ); end




    ## add some predefined/built-in header(s) convenience shortcuts
    def content_type
      ## check: change to headers['content-type'] or such - why? why not?
      @response.content_type
    end
    def content_length
      @response.content_length
    end

    def image_jpg?()   content_type.match?( %r{image/jpeg}i );   end
    def image_png?()   content_type.match?( %r{image/png}i );    end
    def image_gif?()   content_type.match?( %r{image/gif}i );    end


    alias_method :image_jpeg?, :image_jpg?
    alias_method :jpeg?, :image_jpg?
    alias_method :jpg?, :image_jpg?
    alias_method :png?, :image_png?
    alias_method :gif?, :image_gif?

end ##  class Response
end  # class Webclient
