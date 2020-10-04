require 'pp'
require 'time'
require 'date'
require 'fileutils'

require 'uri'
require 'net/http'
require 'net/https'

require 'json'
require 'yaml'



## our own code
require 'webget/version'   # let version go first
require 'webget/webclient'
require 'webget/webcache'
require 'webget/webget'




############
## add convenience alias for camel case / alternate different spelling
WebCache  = Webcache
WebClient = Webclient
WebGet    = Webget

## use Webgo as (alias) name (keep reserver for now) - why? why not?
WebGo    = Webget
Webgo    = Webget


puts Webget.banner   # say hello
