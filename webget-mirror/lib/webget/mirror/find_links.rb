


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


      ## double assert
      ## assert - double check
          ## make sure url.path does NOT start with // or
          ##                              /// !!
         ##  and does NOT end_with /
         ##    pages
           if  base_url.path.start_with?( '//' ) ||
               base_url.path.end_with?( '/' ) ||
              !base_url.path.start_with?( '/' )   ## note - MUST start with single slash (/)
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
    links = doc.css('a').map { |a| a['href'] }.compact

    ## split into internal & external
    ## make links absolute

    anchors = []
    pages = []
    externals = []
    links.each do |href|

                    ## strip leading & trailing spaces e.g.
                    ##   "http://www.danskfodbold.dk "
                    ##    is invalid uri!!!

                    href = href.strip

###
###
##     fix - move into site config!!!!

##
## auto-fix ("site-wide") known quirks:
##   www.rsssf.org/miscellaneous/penalties.html =>
##               /miscellaneous/penalties.html
                 href = href.sub( %r{^www.rsssf.org}i, '' )
##
##   http.//  => http://
                 href = href.sub( %r{^http\.//}i, 'http://' )
##   .html.html  => .html
##   e.g.  /tablesf/francarib2010.html.html
##         /tablest/tsje22.html.html
                 href = href.sub( %r{\.html\.html}i, '.html' )



              ## note - skip mailto links
                next   if /\Amailto/i.match?( href )

                ## also skip broken mailto links
                ##   that is, missing mailto
                ##  e.g.
                next   if href.include?( '@' )



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
                        if href.start_with?("//")
                           puts "!!! debug break on href starting with //:"
                           pp  href
                           pp  url
                           pp  base_url
                           exit 1
                        end

                        ## quick fix for anchors with spaces
                        ### ex:bad URI(is not URI?): "#Northern Ireland"
                        if href.start_with?('#')
                          ###   #Northern Ireland  =>  #Northern-Ireland
                          ###   #Faroe Islands     =>  #Faroe-Islands
                          href = href.gsub( ' ', '-' )
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


                      if page_url.host == site.host    ## e.g. 'rsssf.org'
                          if page_url.path == base_url.path
                                 puts "   anchor  #{href}  =>  #{page_url.fragment}"     if verbose
                              anchors << page_url.fragment
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

        if   page_url.path.start_with?( '//' ) ||
             page_url.path.end_with?( '/' ) ||
            !page_url.path.start_with?( '/' )
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
     anchors   = anchors.uniq
     externals = externals.uniq

      if verbose
      puts "   #{pages.size} internal (& #{anchors.size} anchor) & #{externals.size} external link(s) found in #{base_url.path}:"


    pp pages
    pp anchors
    pp externals
      end

    [pages, externals]
end
