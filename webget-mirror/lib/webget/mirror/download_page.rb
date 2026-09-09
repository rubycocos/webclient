

class Webget
  class Mirror


def _download_page( url,
                    encoding: nil,
                    force: false )

##
## note - on windows cached will be CASE-INSENSITIVE
##       e.g. usadave and USAdave will match
##    make sure match is CASE-SENSITIVE!!!

          if force == false && Webcache.cached?( url )
              puts "   CACHE HIT - #{url}"
              html  = Webcache.read( url )

              return [html,nil]
          end


        puts "==> download #{url} (encoding: #{encoding})..."


    ## note: assume plain 7-bit ascii for now
    ##  -- assume rsssf uses ISO_8859_15 (updated version of ISO_8859_1)
    ###-- does NOT use utf-8 character encoding!!!
    response = Webget.page( url, encoding: encoding )  ## fetch (and cache) html page (via HTTP GET)

    ## note: exit on get / fetch error - do NOT continue for now - why? why not?
    ## note -    allow 404 not found to pass through


    ## note - status.code is an integer number (not a string!!)
    if response.status.code == 404

        meta = {
           http_status:     response.status.code,
        }

        ["404 NOT FOUND",meta]

    elsif response.status.code == 200
      puts "html:"
      html =  response.text
      pp html[0..200]

      ## note - use "hacky" undocument internal response._text_encoding
      ##                   to get "upstream" encoding used from convert to utf-8
      ##                         unicode boms may override user supplied encoding!!!
      ##  or change upstream
      ##   and    use/add response.text_with_encoding( ) - why? why not?
      ##   yes, upstream now uses
      ##    text( encoding: _encoding_user )!!!


      meta = {
          encoding:         response._text_encoding,
          encoding_source:  response._text_encoding_source,  ## bom|http|html|user|fallback
          encoding_valid:   response._text_encoding_valid,

          ascii7bit:         response._text_ascii_only,
          chars_8bit:        response._text_8bit,
          utf8_replace:      response._text_utf8_replace,

          http_content_type:     response.content_type,
          http_content_length:   response.content_length,
          http_status:           response.status.code,
      }

        [html,meta]

    else
       puts "unexpected http status (code) - #{response.status}"
       exit 1
    end
end


end ## class Mirror
end ## class Webget
