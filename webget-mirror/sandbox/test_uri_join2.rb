require 'uri'



base_url_str = 'https://rsssf.org'
base_url     = URI( base_url_str )

pp base_url
puts base_url.to_s

puts URI.join( base_url_str, 'curtour.html' )
puts URI.join( base_url_str, '/curtour.html' )
puts URI.join( base_url, 'curtour.html' )
puts URI.join( base_url, '/curtour.html' )

puts URI.join( base_url, '//curtour.html' )
#=> https://curtour.html
puts URI.join( base_url, '//tables/30f.html' )
#=> https://tables/30f.html

puts URI.join( base_url, '///curtour.html' )
#=>  https://rsssf.org/curtour.html


pp url = URI.join( base_url, '///tables/30f.html' )
pp url.to_s
pp url.host
pp url.path
#=> https://rsssf.org/tables/30f.html


pp url = URI( 'https://rsssf.org/' )
pp url.to_s
pp url.host
pp url.path

pp url = URI( 'https://rsssf.org//' )
pp url.to_s
pp url.host
pp url.path

pp url = URI( 'https://rsssf.org///' )
pp url.to_s
pp url.host
pp url.path


pp url = URI.join( 'https://rsssf.org/', '///curtour.html' )
pp url.to_s
pp url.host
pp url.path

pp url = URI.join( 'https://rsssf.org/', '/curtour.html' )
pp url.to_s
pp url.host
pp url.path

pp url = URI.join( 'https://rsssf.org/', 'curtour.html' )
pp url.to_s
pp url.host
pp url.path

pp url = URI.join( URI('https://rsssf.org/'), URI('curtour.html') )
pp url.to_s
pp url.host
pp url.path

pp url = URI('curtour.html')
pp url.to_s
pp url.host
pp url.path

pp url = URI.join("https://rsssf.org/", "//tabless/spl1909.html")
pp url.to_s
pp url.host
pp url.path

pp url = URI.join( URI("https://rsssf.org/"), "//tabless/spl1909.html")
pp url.to_s
pp url.host
pp url.path


pp url = URI.join( "https://rsssf.org/", "///tabless/spl1909.html" )
pp url.to_s
pp url.host
pp url.path

pp url = URI( "///tabless/spl1909.html" )
pp url.to_s
pp url.host #=> nil
pp url.path #=> /tabless/spl1909.html

pp url = URI( "//tabless/spl1909.html" )
pp url.to_s
pp url.host  #=> tabless
pp url.path  #=> /spl1909.html

pp url = URI( "//x/tabless/spl1909.html" )
pp url.to_s
pp url.host
pp url.path

pp url = URI( "https://rsssf.org///tablesd/duit1909.html" )
pp url.to_s
pp url.host
pp url.path #=> ///tablesd/duit1909.html



pp url = URI.join( "https://rsssf.org/foo/", "../bar" )
pp url.to_s
pp url.host
pp url.path


pp url = URI.join( "https://rsssf.org", "//cdn.example.com/x.js" )
pp url.to_s
pp url.scheme
pp url.host
pp url.path

pp url = URI.join( "https://rsssf.org", "/cdn.example.com/x.js" )
pp url.to_s
pp url.scheme
pp url.host
pp url.path

pp url = URI.join( "https://rsssf.org/tables/tour.html", "/cdn.example.com/x.js" )
pp url.to_s
pp url.scheme
pp url.host
pp url.path

pp url = URI.join( "https://rsssf.org/tables/tour.html", "///cdn.example.com/x.js" )
pp url.to_s
pp url.scheme
pp url.host
pp url.path


pp url = URI( "1"  )
pp url.to_s
pp url.host
pp url.path
pp url.fragment

pp url = URI( "#1"  )
pp url.to_s
pp url.host
pp url.path
pp url.fragment

pp url = URI( "../tabels/30f.html"  )
pp url.to_s
pp url.scheme
pp url.host
pp url.path
pp url.fragment


path = "///tabless/spl1907.html"
pp File.dirname( path )                        #=> "//tabless/spl1907.html" !!!
pp File.extname( path )                        #=> ".html"
pp File.basename( path, File.extname( path ))  #=> "/"

path = "//tabless/spl1907.html"
pp File.dirname( path )                        #=> "//tabless/spl1907.html" !!!
pp File.extname( path )                        #=> ".html"
pp File.basename( path, File.extname( path ))  #=> "/"

path = "/tabless/spl1907.html"
pp File.dirname( path )                        #=> "/tabless"
pp File.extname( path )                        #=> ".html"
pp File.basename( path, File.extname( path ))  #=> "spl1907"


###
## <a href="..//nersssf.html">
##  in https://rsssf.org/tablesp/poland-satrip77.html

pp url = URI.join( "https://rsssf.org/tablesp/poland-satrip77.html",
                   "..//nersssf.html" )
pp url.to_s
pp url.scheme
pp url.host
pp url.path
pp url.fragment


puts
puts "==============="
###  check    fragements without #

pp url = URI( '42')
pp url.to_s
pp url.scheme     #=> nil
pp url.host       #=> nil
pp url.path       #=> "42"
pp url.fragment   #=> nil


pp url = URI( '#champ' )
pp url.to_s
pp url.scheme     #=> nil
pp url.host       #=> nil
pp url.path       #=> ""
pp url.fragment   #=> "champ"


pp url = URI( '42#champ' )
pp url.to_s
pp url.scheme    #=> nil
pp url.host      #=> nil
pp url.path      #=> "42"
pp url.fragment  #=> "champ"


puts "bye"





__END__

url = "https://user:pass@example.com:8080/path/page.html?foo=1&bar=2#section-3"
uri = URI.parse(url)

puts uri.scheme    # "https"
puts uri.user      # "user"
puts uri.password  # "pass"
puts uri.host      # "example.com"
puts uri.port      # 8080
puts uri.path      # "/path/page.html"
puts uri.query     # "foo=1&bar=2"
puts uri.fragment  # "section-3"
