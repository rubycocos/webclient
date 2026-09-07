
class Webclient
  class Response


   # regex to capture the charset from both HTML5 and HTML4 meta tags
   # --  the modern HTML5 <meta charset="..."> tag, or
   # --  the older HTML4 <meta http-equiv="Content-Type" ...> tag
   ##   <meta http-equiv="Content-Type" content="text/html;
   ##          charset=windows-1252"
   ##     support multi-line (m) - why? why not???
   ##
   ## note - add the n (NOENCODING) flag
   ##  The n flag forces Ruby to compile and process the regex as a raw sequence of bytes
   ##    (ASCII-8BIT). This allows it to safely match against US-ASCII, ASCII-8BIT,
   ##   or UTF-8 strings without throwing compatibility errors
   ##  charset
   ###   note - charset class was [^"' >]+ changed to more strict/simple [a-z0-9-_]+
   ##   check if other "weirdo" encoding name exist?
     HTML_CHARSET_RE = %r{ <meta [^>]+
                            charset [ ]* = [ ]*
                                    ["']? (?<charset> [a-z0-9_-]+)
                        }ixn

     HTML_CHARSET_ALIASES = {
       'utf8'          => 'UTF-8',
       'utfs-8'        => 'UTF-8',     ## typo in rsssf (fix otherwise or here??)
       'cp1252'        => 'Windows-1252',
       'latin1'        => 'ISO-8859-1',
       'ascii'         => 'US-ASCII',
       'binary'        => 'ASCII-8BIT'
     }



    ### internal helper
    ###    to get "upstream" encoding
    ###         note - unicode bom will override user encoding !!!
    ##  -- use _text_encoding_upstream or such - why? why not?
    ##   change/rename _8bit to chars_8bit - why? why not?

    def _text_encoding()        defined?( @_text_encoding )        ?  @_text_encoding : nil;  end
    def _text_encoding_source() defined?( @_text_encoding_source ) ?  @_text_encoding_source : nil; end

    def _text_encoding_valid()  defined?( @_text_encoding_valid)   ?  @_text_encoding_valid : nil;  end
    def _text_ascii_only()      defined?( @_text_ascii_only )      ?  @_text_ascii_only   : nil;  end
    def _text_8bit()            defined?( @_text_8bit )            ?  @_text_8bit         : nil;  end
    def _text_utf8_replace()    defined?( @_text_utf8_replace )    ?  @_text_utf8_replace : nil; end



    ##   use encoding: nil   (with fallback 'UTF-8')
    ##      lets us check if user encoding passed in or
    ##                    if default fallback used !!!!
    ##   use for encoding_source (hierarchy) !!
    ##       e.g.   bom|html|http| user or fallback
    ##
    ##    or use a new force_encoding property/option for user
    ##          e.g.  bom|  force| html|http|...

    ## todo/check: rename encoding to html/http-like charset - why? why not?
    ##    or keep encoding as used for ruby's strings
    def _decode_text( encoding: _encoding_user )

      if encoding.nil?
        encoding = 'UTF-8'     ### use UTF-8 as fallback (default encoding)
        encoding_source = 'fallback'
      else
        encoding_source = 'user'
      end


      # note: Net::HTTP will NOT set encoding UTF-8 etc.
      # will be set to ASCII-8BIT == BINARY == Encoding Unknown; Raw Bytes Here
      ##
      ## todo/assert
      ##   make sure encoding is  ASCII-8BIT == BINARY !!!
      ##
      ## note !!!! - make sure text is always a copy (thus, use dup(licate)!!)
      ##              NOT a reference to @response.body.to_s
      ##                otherwise force_encoding
      ##                    will change the encoding "upstream"
      text = @response.body.b.dup



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
         'UTF-32BE'
      elsif text.start_with?("\xFF\xFE\x00\x00".b)
         text = text.byteslice(4..)
         'UTF-32LE'
      elsif text.start_with?("\xFE\xFF".b)
         text = text.byteslice(2..)
         'UTF-16BE'
      elsif text.start_with?("\xFF\xFE".b)
         text = text.byteslice(2..)
         'UTF-16LE'
      elsif text.start_with?("\xEF\xBB\xBF".b)
         text = text.byteslice(3..)
         'UTF-8'
      else
         nil   # no bom found
      end




      if encoding_bom
        puts "  [debug] auto-removing unicode >#{encoding_bom}< encoding bom (magic bytes) in response.text"

        if encoding_bom.downcase != encoding.downcase
          puts "  [debug] !!! WARN - auto-fixing response.text encoding; >#{encoding}< overridden by >#{encoding_bom}< unicode encoding bom"
          encoding = encoding_bom
        end

        encoding_source = 'bom'
      else
         ##   fix-fix-fix   check/add http content type check with charset!!
         ##
         ##  check if html content type
         ##     text/html
         ##     application/xhtml+xml
         ##          && check html meta charset in page in first 1028 bytes
         ##
         ##  note - content_type might return nil (guard with to_s!!)
         ##   maybe use/make into  html? helper like gif? pdf? or such

          if content_type.to_s.match?( %r{text/html}i ) ||
             content_type.to_s.match?( %r{application/xhtml}i )

             if (m = HTML_CHARSET_RE.match( text[0, 1028] ))
                 encoding_html =  m[:charset]
                 ## note - normalize encoding_html
                 ##    plus fix known type errors!!!
                 encoding_html = HTML_CHARSET_ALIASES[ encoding_html.downcase ] || encoding_html


                 ## change/replace  ISO-8859-1 with Windows-1252 !!
                 ##  Why CP1252 (Windows-1252) is swapped for ISO-8859-1
                 ##   The script safely
                 ##   swaps ISO-8859-1 out for CP1252 (Windows-1252).
                 ##  Legally, the standard ISO-8859-1 encoding leaves bytes 128–159 empty
                 ##  for control characters.
                 ##  Microsoft's CP1252 fills those blank slots with highly common formatting marks
                 ##  like the smart quotes (“”), the trademark symbol (™), and the en-dash (–).
                 ##
                 ##  Web browsers inherently treat ISO-8859-1 text as Windows-1252 to avoid breaking these common symbols, and this script mimics that behavior.

                 encoding_html = 'Windows-1252'  if encoding_html.downcase == 'ISO-8859-1'



                 ## fix-fix-fix
                 ##  validate with ruby's builtin in encoding registry!!!
                 # 3. Validate against Ruby's internal encoding registry
                 ## begin
                 ##   Encoding.find(standard_name).name
                 ## rescue ArgumentError
                 ##     unknown encoding!!!
                 ## end

                 if encoding_html.downcase != encoding.downcase
                    ## note  - change WARN to INFO
                    puts "  [debug] !!! WARN - overwrite response.text encoding; >#{encoding}< overridden by >#{encoding_html}< html meta charset"
                    encoding = encoding_html
                 end

                 encoding_source = 'html'
            end
          end
      end


##
##    note - allow "hack-y" access to "upstream" encoding used before conversion to utf-8
##             e.g. use   response._text_encoding or
##                        response._text_encoding_source  (e.g. bom|html|http|user)
          @_text_encoding        = encoding
          @_text_encoding_source = encoding_source

###
###    if encoding.start_with? utf
##           or has encoding_bom
###       do nothing
##      otherwise
##           tally all 8-bit ascii chars (above > 127)

      if encoding_bom || encoding.downcase.start_with?( 'utf' )
           @_text_8bit = nil
      else
         ## get/track 8-bit bytes (1xxxxxxx), that is, > 127 (128-255)
         bytes  = text.bytes.select { |byte| byte > 127 }

         if bytes.empty?
           @_text_8bit = nil
         else
           @_text_8bit = "#{bytes.count} - "
           ##  bytes.tally
           ## e.g.  {195=>1, 169=>1, 240=>1, 159=>1, 152=>1, 138=>1}
           ##    note - use sort (turns in array e.g. [[138,1],...])
           @_text_8bit += bytes.tally.sort.map {|ord,count| "#{ord}=>#{count}"}.join(', ')
         end
      end






      if encoding.downcase == 'utf-8'
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

          ## note be more tolerant when converting - use replace for now - why? why not?
          ##   maybe add a strict (no replace) version later
             text = text.encode(
                      Encoding::UTF_8,
                         invalid: :replace,
                         undef:   :replace,
                         replace: "�"
                      )

               errors = text.scan( "�" )
               if errors.size > 0
                  puts "  [debug] !!! WARN - #{errors.size} invalid/undef character encoding error(s) replaced w/ �"
                  @_text_utf8_replace = errors.size
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

     ###
     ##  todo/check -  add nfc: true|false
     ##                   to text() as option (if unicode - utf8)  - why? why not?
     ##                or text_unicode( nfc: true|false )

     ##  comment out for now - get
     ##    unicode_normalize/normalize.rb:126:in `gsub': invalid byte sequence in UTF-8
      text = text.unicode_normalize(:nfc)

      text
    end

end # class Response
end  # class Webclient
