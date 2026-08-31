


def _download_page( url,
                    encoding:,
                    force: )


  ## check if not in cache
  ##   note - use force == true  to always (force) download

##
## note - on windows cached will be CASE-INSENSITIVE
##       e.g. usadave and USAdave will match
##    make sure match is CASE-SENSITIVE!!!

    if force == false && Webcache.cached?( url )
        puts "   CACHE HIT - #{url}"
        html = Webcache.read( url )
        [html, nil]
    else
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
           status:          response.status.code,
        }

        ["404 NOT FOUND",meta]

    elsif response.status.code == 200
      puts "html:"
      html =  response.text( encoding: encoding )
      pp html[0..200]

      ## note - use "hacky" undocument internal response._text_encoding
      ##                   to get "upstream" encoding used from convert to utf-8
      ##                         unicode boms may override user supplied encoding!!!
      ##  or change upstream
      ##   and    use/add response.text_with_encoding( ) - why? why not?

      meta = {
          encoding:        response._text_encoding,
          content_length:  response.content_length,
          content_type:    response.content_type,
          status:          response.status.code,
      }

        [html,meta]

    else
       puts "unexpected http status code - #{response.status.code}"
       exit 1
    end
  end
end



__END__

TITLE_RE = %r{
    <TITLE>(?<text>.*?)</TITLE>
}ixm



https://rsssf.org/miscellaneous/ec-qual.html

minimal page with no title   uses <head/> !!!
e.g
<html>
<head/><pre>
Contributed by ...
</pre>
</html>


if encoding == 'windows-1252'
            ## try a quick check if proper encoding
            ## search for title in page
           if  m=TITLE_RE.match( html )
              puts "  page title: #{m[:text].strip}"
           else
             puts "error - no title found in html - encoding error?"
             exit 1
           end
        end

or


<head/><pre>
Austria, OeFB ("Magnofit") Cup 1996/97
  ...
<p>
Last updated: 28 May 1997

</pre>
  in https://rsssf.org/tableso/oostcup97.html
