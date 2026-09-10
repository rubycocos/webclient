

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
                    href.match?( /\A(?:javascript|mailto|tel|data):/i ) ||

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
        href = site.autofix_href( href )    if site.autofix_href?


                      page_url = nil
                      begin
                        ## try to make absolute (relative to base_url)
                        page_url = URI.join(base_url, href)

                        ###  note - skip any other schemes (ftp? or ??)
                        ##           not already excluded above
                        next  unless %w[http https].include?(page_url.scheme)

                      rescue => ex
                         ## skip bad urls and log
                         ###    only catch URI::InvalidURIError - why? why not?

                         msg = "bad url in #{base_url.path}:\n#{href}\nex:#{ex}\n"

                         ## note - only report in verbose mode (fresh download or such)!!!
                         if verbose
                           log( msg )
                           puts "!! " + msg
                         end

                         next
                      end

                      ##
                      ##  use downcase (case insensitive) for edge case
                      ##     RSSSF.ORG == rsssf.org or such  - why? why not?
                      ##  note - yes, .host is ALWAYS downcased by URI#host !!!!

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
        puts "     #{pages.size} internal & #{externals.size} external link(s) found in #{base_url.path}"
        ## pp pages
        ## pp externals
      end

    [pages, externals]
end


end  ## class Mirror
end  ## class Webget
