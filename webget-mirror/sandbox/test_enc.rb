####
#  to run use:
#
#    $ ruby sandbox/test_enc.rb

require_relative 'helper'



url = "https://rsssf.org/tablest/turkm2026.html"
##
## =>  [debug] auto-removing unicode >UTF-16LE< encoding bom (magic bytes) in response.text
##     [debug] !!! WARN - auto-fixing response.text encoding; >windows-1252< overridden by >UTF-16LE< unicode encoding bom
##     [debug] try converting response.text encoding from >UTF-16LE< to >UTF-8<


# url = "https://rsssf.org/tablesc/caribe2016.html"
##
## =>  [debug] try converting response.text encoding from >windows-1252< to >UTF-8<
##     [debug] !!! WARN - 4 invalid/undef character encoding error(s) replaced w/ �



response = Webclient.get( url )
html = response.text( encoding: 'windows-1252')

pp html[0,100]
puts "---"
puts html
pp html.encoding

puts "bye"




__END__

before:
GET https://rsssf.org/tablest/turkm2026.html...
"\xFF\xFE<\u0000!\u0000D\u0000O\u0000C\u0000T\u0000Y\u0000P\u0000E\u0000 \u0000H\u0000T\u0000M\u0000L\u0000 \u0000P\u0000U\u0000B\u0000L\u0000I\u0000C\u0000 \u0000\"\u0000-\u0000/\u0000/\u0000W\u00003\u0000C\u0000/\u0000/\u0000D\u0000T\u0000D\u0000 \u0000H\u0000T\u0000M\u0000L\u0000 \u00003\u0000.\u00002\u0000 \u0000F\u0000i\u0000n\u0000a\u0000l\u0000"

after:
