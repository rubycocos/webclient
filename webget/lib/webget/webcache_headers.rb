
module Webcache

  ##############################
  # nested class for convenience access to (meta) headers


  class Headers      ## todo/check - rename to Meta or such - why? why not?


    ##  def self.read( path ) parse(read_text( path )); end



    def self.parse( txt )
      data = {}
      txt.each_line do |line|
         line = line.strip
         next  if line.empty? || line.start_with?( '#' )

         key, value = line.split( ':', 2 )  ## split on first colon

         ##  todo/fix: deal with possible duplicate header keys!!
         ##   if duplicate do NOT replease, add with leading ", " comma-separated!!!
         ##
         ##  check if multi-line headers are possible!!!
         ##   and than may turn value into array of values - why? why not?
         ##    or auto-add


         ## note - always downcase keys for now
         ##  and strip value from leading and trailing spaces
         data[ key.strip.downcase ] = value.strip
      end
      new( data )
    end



    def initialize( data )
      @data = data
    end

    def to_h() @data; end
    def [](key) @data[key]; end

    def each( &blk )
      @data.each do |key, value|
        blk.call( key, value )
      end
    end



    def date
       ## return date header
       ##  parses the time as RFC 1123 date of HTTP-date defined by RFC 2616:
       ##    day-of-week, DD month-name CCYY hh:mm:ss GMT
       ##   !!! Note that the result is always UTC (GMT). !!!
       ##   e.g. Sun, 19 May 2024 15:15:34 GMT
       ##        Mon, 10 Jun 2024 15:58:16 GMT
       @date ||= Time.httpdate( @data['date'] )
       @date
    end

    ## default to 12h (60secs*60min*12h)
    def expired?( expires_in_date=Time.now.utc-60*60*12 )
      ## pp expires_in_date
      expires_in_date > date
    end

    ## add convenience helpers - why? why not?
    def expired_in_12h?() expired?( Time.now.utc-60*60*12 ); end
    def expired_in_24h?() expired?( Time.now.utc-60*60*24 ); end
    alias_method :expired_in_1d?, :expired_in_24h?
  end # class Headers


end  ## module Webcache
