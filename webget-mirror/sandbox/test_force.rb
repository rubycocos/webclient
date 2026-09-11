
require_relative 'helper'


Webcache.root = './cache'


## GET https://rsssf.org/tablesa/argchamp.html...
##    <meta http-equiv="Content-Type" content="text/html; charset=UTFs-8">
##    [debug] !!! WARN - overwrite response.text encoding; >windows-1252< overridden by >UTF-8< html meta charset
##       unicode_normalize/normalize.rb:126:in `gsub': invalid byte sequence in UTF-8 (ArgumentError)



url = 'https://rsssf.org/tablesa/argchamp.html'
##
## res = Webget.page( url, encoding: 'windows-1252', force_encoding: true  )
res = Webget.page( url, force_encoding: 'windows-1252' )

pp res.status
pp res.text[0,200]

pp res._text_encoding
pp res._text_encoding_source
pp res.text.encoding


## [cache] saving   cache/rsssf.org/tables/2002full.html...
##  [debug] !!! WARN - overwrite response.text encoding; >windows-1252< overridden by >UTF-8< html meta charset
##     unicode_normalize/normalize.rb:126:in `gsub': invalid byte sequence in UTF-8

url = 'https://rsssf.org/tables/2002full.html'
res = Webget.page( url, force_encoding: 'windows-1252' )

pp res.status
pp res.text[0,200]

pp res._text_encoding
pp res._text_encoding_source
pp res.text.encoding



puts "bye"