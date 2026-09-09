require 'uri'


pp URI.join("http://example.com", "users").to_s    #=> "http://example.com/users"
pp URI.join("http://example.com/", "users").to_s   #=> "http://example.com/users"

pp URI.join("http://example.com", "/users").to_s  #=> "http://example.com/users"
pp URI.join("http://example.com/", "/users").to_s  #=> "http://example.com/users"


puts "---"
pp URI.join( URI("http://example.com"),  URI("users")).to_s
pp URI.join( URI("http://example.com/"), URI("users")).to_s

pp URI.join( URI("http://example.com"),  URI("/users")).to_s
pp URI.join( URI("http://example.com/"), URI("/users")).to_s

puts "---"
pp URI("http://example.com")             ## <URI::HTTP http://example.com>
pp URI("http://example.com").path        ## path => ""  !!!

pp URI("http://example.com/")            ## <URI::HTTP http://example.com/>
pp URI("http://example.com/").path       ## path => "/"


puts "---"
pp URI("users")    ## <URI::Generic users>
pp URI("users").path
pp URI("/users")   ## <URI::Generic /users>
pp URI("/users").path


#########
##  protocol-relative URLs
##
## HTML commonly contains:
##   <a href="//example.com/foo">
##
## That's a network-path reference, not an absolute URI. URI.join handles it nicely:

pp URI.join("https://my-site.com/a/b", "//example.com/foo")   ## <URI::HTTPS https://example.com/foo>

pp URI.join(URI("https://my-site.com/a/b"), "//example.com/foo")
pp URI.join(URI("https://my-site.com/a/b"), URI("//example.com/foo"))


pp URI.join("https://my-site.com", "//example.com/foo")   ## <URI::HTTPS https://example.com/foo>

pp URI.join(URI("https://my-site.com"), "//example.com/foo")
pp URI.join(URI("https://my-site.com"), URI("//example.com/foo"))


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
       ##
       ## if href.start_with?("//")
       ##                    puts "!!! debug break on href starting with //:"
       ##                    pp  href
       ##                    pp  url
       ##                    pp  base_url
       ##                    exit 1
       ##                 end


puts "bye"