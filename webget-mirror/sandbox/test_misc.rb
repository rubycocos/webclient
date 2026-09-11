####
#  to run use:
#
#    $ ruby sandbox/test_misc.rb

require_relative 'helper'


require 'nokogiri'



# <!DOCTYPE html>
# <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
# <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://w3.org">

html =<<HTML
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
  <html>
    <body>
      <p>Hello World</p>
    </body>
  </html>
HTML

doc = Nokogiri::HTML(html)
doctype = doc.internal_subset

puts doctype.name        # => "html"
puts doctype.external_id # => "-//W3C//DTD HTML 4.01//EN"
puts doctype.system_id   # => "http://w3.org"

## puts doctype.to_s        # => "<!DOCTYPE html>"
## note - doctype.to_s returns   empty string ""


__END__


## <meta charset="utf-8">
## <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

### try to get doctype
html =<<HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<HTML>
<HEAD>
<TITLE>The Introduction Page of the RSSSF -- The Rec.Sport.Soccer Statistics Foundation.</TITLE>

<!-- will not match -->
<script src="app.js" charset="UTF-8">

<meta http-equiv="Content-Type" content="text/html; charset=ISO-81">
</HEAD>
<BODY>
</BODY>
HTML


pp html

doc = Nokogiri::HTML( html )
pp doc.internal_subset.to_s
pp doc.meta_encoding
## pp doc.doctype

if m=Webget::Mirror::HTML_CHARSET_RE.match( html[0,1028] )
     puts "  charset >#{m[:charset]}<"
end

if m=Webget::Mirror::HTML_DOCTYPE_RE.match( html )
     puts "  doctype >#{m[:doctype]}<"
end

html =<<HTML
<!DOCTYPE html>
<html>
<meta charset="Windows-1256">
<body></body>
</html>
HTML


doc = Nokogiri::HTML( html )
pp doc.internal_subset.to_s
pp doc.meta_encoding

if m=Webget::Mirror::HTML_CHARSET_RE.match( html )
     puts "  charset >#{m[:charset]}<"
end
if m=Webget::Mirror::HTML_DOCTYPE_RE.match( html )
     puts "  doctype >#{m[:doctype]}<"
end


###
##  test (case-sensitive) cache check
##  /usadave/alpf.html
##  /USAdave/alpf.html


url = "https://rsssf.org/USAdave/alpf.html"
puts "#{url}:"
## pp  Webcache.cached?( url, strict: false )
## pp  Webcache.cached?( url, strict: true )
pp  Webcache.cached?( url )

path =  "#{Webcache.root}/rsssf.org/USAdave/alpf.html"
puts "#{path}:"
pp File.exist?( path )
pp File.realpath( path )
pp File.expand_path( path )

path =  "#{Webcache.root}/rsssf.org/usadave/alpf.html"
puts "#{path}:"
pp File.exist?( path )
pp File.realpath( path )
pp File.expand_path( path )



puts "bye"