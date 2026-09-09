

class Webget
  class Mirror


   ## double assert
      ## assert - double check
          ## make sure url.path does NOT start with // or
          ##                              /// !!
         ##  and does NOT end_with /
         ##    pages

def _broken_path?( path )
      path.start_with?( '//' ) ||
      path.end_with?( '/' ) ||
     !path.start_with?( '/' )  ## note - MUST start with single slash (/)
end



## get all links
##   ignore anchor links and
##     split into internal and external
def _find_links( site:,
                 doc:,
                 url:,
                 verbose: true )


       ## note - base_url is  the doc(ument) url
       ##                            e.g.  https://rsssf.org/curtour.html
       base_url = URI( url )


           if _broken_path?( base_url.path )
              puts "!! normalized base_url.path expected  - got:"
              pp url
              pp base_url
              exit 1
           end

    ##
    ## note: Array#compact removes all nil values from an array.
    ##    if no href in a - nokigiri return nil
    ##
    ##     might still incl. empty string ("") - remove too - why? why not?

    ##
    ##  fix - change to css('a[href]') or such ??
    ###     document.css("a[href]").each do |a|
    ## links = doc.css('a').map { |a| a['href'] }.compact


    links = doc.css( 'a[href]' ).map do |a|
                    ## strip leading & trailing spaces e.g.
                    ##   "http://www.danskfodbold.dk "
                    ##    is invalid url!!!
                    a['href'].strip
                end.reject do |href|
                    # skip
                    #  - empty strings,
                    #  - page anchors
                    href.empty? || href.start_with?('#') ||

                    ##  skip mailto links/javascript snippets
                    href.match?( /\A(?:mailto|javascript)/i ) ||

                     ## also skip broken mailto links
                     ##   that is, missing mailto
                     ##  e.g.
                     href.include?( '@' )
                end


    ## split into internal & external
    ## make links absolute
    ##   ignore anchor links (see above)

    pages     = []
    externals = []

    links.each do |href|

        ##
        ## auto-fix ("site-wide") known quirks:
        href = site.autofix_href.call( href )    if  site.autofix_href.is_a?( Proc )


                      page_url = nil
                      begin

                        ## special case
                        ##  check for protocol-relative  //  e.g. //hello.html
                        ##    NOT handled by URI
                        ##       URI makes hello.html into host !!!
                        ##                host is hello.html and path is nil
                        ##        only works properly with triple ///
                        ##             e.g. ///hello.html
                        ##              now host is nil, and path is /hello.html

      ##   URI.join(URI("https://example.com/page.html"), "//cdn.example.com/file.js")
      ##  # => #<URI::HTTPS https://cdn.example.com/file.js>  ✓ Works!
      ##
      ##   But with just the string:
      ##    URI("//cdn.example.com/file.js")
      ##     Parses incorrectly—no scheme, treats cdn.example.com as host  !!!!!


       ##  The browser breaks down //path/page.html like this:
       ##  - Protocol: Inherited from the current page (e.g., https:).
       ##  - Domain (Authority): path
       ##  - File Path: /page.html
       ##
       ## If your website is hosted on https://example.com and
       ## a user clicks <a href="//path/page.html">, the browser will try
       ## to navigate to https://path/page.html.
       ## Unless you own a domain name that is literally just path,
       ##  this will result in a "Site cannot be reached" error.
       ###
       ###  "legacy" protocol relative is "//://" !!!!
       ##
       ##   move notes from here to dedicated notes page!!



                        if href.start_with?("//")
                           puts "!!! debug break on href starting with //:"
                           pp  href
                           pp  url
                           pp  base_url
                           exit 1
                        end



                        ## check if href is absolute?
                        href_url = URI( href )

                        ## assume already absolute
                        if href_url.scheme && href_url.host
                          page_url = href_url
                        else
                          ## try to make absolute (relative to base_url)
                          page_url = URI.join(base_url, href_url)
                        end

                      rescue => ex
                         ## skip bad urls and log

                         msg = "bad url in #{base_url.path}:\n#{href}\nex:#{ex}\n"

                         ## note - only report in verbose mode (fresh download or such)!!!
                         if verbose
                           log( msg )
                           puts "!! " + msg
                         end

                         next
                      end

                      ###
                      ##  fix-fix-fix
                      ##    check for  optional www too
                      ##          assume same for now ??
                      ##    or better add to autofix
                      ##            if www.rsssf.org  change to  rsssf.org

                      if page_url.host == site.host    ## e.g. 'rsssf.org'
                          if page_url.path == base_url.path
                                 puts "   anchor  #{href}  =>  #{page_url.fragment}"     if verbose
                          else
                               puts "   internal page  #{href}  =>  #{page_url.path}"     if verbose

                               ## note - for internal pages
                               ##  for now no SUPPORT for query
                               ##    e.g. foo=1&bar=2
                               if page_url.query
                                   ## change to ValueError or such - why? why not?
                                   ## raise ArgumentError, "query in internal page links not yet supported, sorry - got #{page_url}"
                                   msg = "query in internal page links not yet supported, sorry - got #{page_url}"
                                   puts "!! WARN - #{msg}"
                                   log( msg )
                                   next
                               end

        if _broken_path?( page_url.path )
            puts "!! normalized page_url.path expected - got:"
            pp page_url.path
            pp page_url
            puts "base_url:"
            pp url
            pp base_url
            exit 1
          end

                               pages << page_url.path
                          end
                      else
                         puts "!! external  #{href}  =>  #{page_url}"      if verbose
                         externals << page_url.to_s
                      end
                    end

     ## make uniq
     pages     = pages.uniq
     externals = externals.uniq

      if verbose
      puts "   #{pages.size} internal & #{externals.size} external link(s) found in #{base_url.path}:"


    pp pages
    pp externals
      end

    [pages, externals]
end


end  ## class Mirror
end  ## class Webget
