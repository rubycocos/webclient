
class Webclient

  # wrap Net::HTTP::Response
  class Response
    class Status  # nested class  Response::Status
      def initialize( response )
        @response = response
      end

      def http_version() @response.http_version; end
      alias_method :version, :http_version   ## add/keep shorter alias too - why? why not?

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
    def raw() @response; end




    ### internal helper
    ###    to get "upstream" encoding
    ###         note - unicode bom will override user encoding !!!
    ##  -- use _text_encoding_upstream or such - why? why not?

    def _text_encoding_bom()   defined?( @_text_encoding_bom )  ?  @_text_encoding_bom : nil; end
    def _text_encoding()       defined?( @_text_encoding )      ?  @_text_encoding : nil;  end
    def _text_encoding_valid() defined?( @_text_encoding_valid) ?  @_text_encoding_valid : nil;  end
    def _text_ascii_only()     defined?( @_text_ascii_only )    ?  @_text_ascii_only : nil;  end


    ## todo/check: rename encoding to html/http-like charset - why? why not?
    def text( encoding: 'UTF-8' )
      # note: Net::HTTP will NOT set encoding UTF-8 etc.
      # will be set to ASCII-8BIT == BINARY == Encoding Unknown; Raw Bytes Here
      # thus, set/force encoding to utf-8
      text = @response.body.b

      ##
      ## todo/assert
      ##   make sure encoding is  ASCII-8BIT == BINARY !!!

      ## note !!!! - make sure text is always a copy
      ##              NOT a reference to @response.body.to_s
      ##                otherwise force_encoding
      ##                    will change the encoding "upstream"
      text = text.dup


      ##    note  - record 7bit ascii code range (ENC_CODERANGE_7BIT) check (on "raw" blob before changing encoding)
      ##     see https://shopify.engineering/code-ranges-ruby-strings
      ##
      ##  String#ascii_only?
      ##    returns true if every character in the string has a byte value between 0 and 127.
      ##
      ### ENC_CODERANGE_7BIT:
      ##   Every single byte in the string is between 0 and 127.
      ##  If this flag is already set, ascii_only?
      ##  immediately returns true.
      ##
      ##  ENC_CODERANGE_VALID:
      ##    The string contains valid characters for its encoding (like UTF-8),
      ##   but at least one character is outside the 0–127 range
      ##   (e.g., it contains a 128+ byte).
      ## If this flag is set, it immediately returns false.
      ##
      ##
      ##              check before optional bom-removal
      @_text_ascii_only    = text.ascii_only?


      ###
      ##  note
      ## auto-check for unicode byte-order marks (BOM)s!!
      ##   and auto-strip bom!!
      ##
      ##  common BOMs to check
      ##   UTF-8: EF BB BF
      ##   UTF-16 BE: FE FF
      ##   UTF-16 LE: FF FE
      ##   UTF-32 BE: 00 00 FE FF
      ##   UTF-32 LE: FF FE 00 00

      encoding_bom =
      if text.start_with?("\x00\x00\xFE\xFF".b)
         text = text.byteslice(4..)
         "UTF-32BE"
      elsif text.start_with?("\xFF\xFE\x00\x00".b)
         text = text.byteslice(4..)
         "UTF-32LE"
      elsif text.start_with?("\xFE\xFF".b)
         text = text.byteslice(2..)
         "UTF-16BE"
      elsif text.start_with?("\xFF\xFE".b)
         text = text.byteslice(2..)
         "UTF-16LE"
      elsif text.start_with?("\xEF\xBB\xBF".b)
         text = text.byteslice(3..)
         "UTF-8"
      else
         nil   # no bom found
      end


      if encoding_bom
        puts "  [debug] auto-removing unicode >#{encoding_bom}< encoding bom (magic bytes) in response.text"

        if encoding_bom.downcase != encoding.downcase
          puts "  [debug] !!! WARN - auto-fixing response.text encoding; >#{encoding}< overridden by >#{encoding_bom}< unicode encoding bom"
          encoding = encoding_bom
        end
      end

##
##    note - allow "hack-y" access to "upstream" encoding used before conversion to utf-8
##             e.g. use   response._text_encoding_bom or
##                        response._text_encoding
          @_text_encoding_bom = encoding_bom
          @_text_encoding     = encoding


      if encoding.downcase == 'utf-8'
         ## note - get a duplicate
         ##           otherwise
         text = text.force_encoding( Encoding::UTF_8 )

         ## track/check code range if valid/broken
         @_text_encoding_valid = text.valid_encoding?
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
          puts "  [debug] try converting response.text encoding from >#{encoding}< to >UTF-8<"
          text = text.force_encoding( encoding )

          ## track/check code range if valid/broken
          ##   note - check BEFORE conversion to utf-8 - why? why not?
          @_text_encoding_valid = text.valid_encoding?

          replace = true
          if replace
                ## maybe be more tolerant when converting? why? why not?
             text = text.encode(
                      Encoding::UTF_8,
                         invalid: :replace,
                         undef:   :replace,
                         replace: "�"
                      )

               errors = text.scan( "�" )
               if errors.size > 0
                  puts "  [debug] !!! WARN - #{errors.size} invalid/undef character encoding error(s) replaced w/ �"
               end
          else
            text = text.encode( Encoding::UTF_8 )
          end
      end


     # Normalize unicode (utf-8) string to Composed (NFC)
     #    NFC (Normalization Form Canonical Composition)

=begin
  use nfkc ??
  or delegate to userland??

Pro-Tip: Watch out for Ligatures and Compatibility Issues
While NFC handles standard accents beautifully,
you might occasionally want NFKC (Normalization Form Compatibility Composition)
instead.
 pages sometimes contain legacy typographical quirks like:
 Ligatures: The characters ﬁ or ﬂ typed as a single glyph.
 Roman Numerals / Fractions: Characters like Ⅳ or ½.

 If you use standard NFC, those symbols remain as complex single characters.
 If you use NFKC, Ruby will break them down into standard,
 easily searchable text (ﬁ becomes fi, Ⅳ becomes IV, and ½ becomes 1/2).
=end

     text = text.unicode_normalize(:nfc)

      text
    end


    ## convenience helper; returns parsed json data; note: always assume utf-8 (text) encoding
    def json() JSON.parse( text ); end


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

    def image_jpg?()   content_type =~ %r{image/jpeg}i;   end
    def image_png?()   content_type =~ %r{image/png}i;    end
    def image_gif?()   content_type =~ %r{image/gif}i;    end

    alias_method :image_jpeg?, :image_jpg?
    alias_method :jpeg?, :image_jpg?
    alias_method :jpg?, :image_jpg?
    alias_method :png?, :image_png?
    alias_method :gif?, :image_gif?

end ##  class Response
end  # class Webclient
