####
#  to run use:
#
#    $ ruby sandbox/test_force_encoding.rb


require_relative 'helper'


Webcache.root = './cache'


## GET https://rsssf.org/tablesa/argchamp.html...
##    <meta http-equiv="Content-Type" content="text/html; charset=UTFs-8">
##    [debug] !!! WARN - overwrite response.text encoding; >windows-1252< overridden by >UTF-8< html meta charset
##       unicode_normalize/normalize.rb:126:in `gsub': invalid byte sequence in UTF-8 (ArgumentError)

## [cache] saving   cache/rsssf.org/tables/2002full.html...
##  [debug] !!! WARN - overwrite response.text encoding; >windows-1252< overridden by >UTF-8< html meta charset
##     unicode_normalize/normalize.rb:126:in `gsub': invalid byte sequence in UTF-8

urls = [
 ## 'https://rsssf.org/tablesb/baltic01.html',
 ## 'https://rsssf.org/tablesa/argchamp.html',
 ## 'https://rsssf.org/tables/2002full.html',
  'https://rsssf.org/tableso/ol1964q.html',
]

urls.each do |url|
  res = Webget.page( url, force_encoding: 'windows-1252' )

  pp res.status
  pp res.text[0,200]

  pp res._text_encoding
  pp res._text_encoding_source
  pp res.text.encoding
end




puts "bye"