require 'webclient'

## our own code
require 'webget/version'   # let version go first
require 'webget/webcache'
require 'webget/webget'




############
## add convenience alias for camel case / alternate different spelling
WebCache  = Webcache
WebGet    = Webget

## use Webgo as (alias) name (keep reserver for now) - why? why not?
WebGo    = Webget
Webgo    = Webget


puts Webget.banner   # say hello
