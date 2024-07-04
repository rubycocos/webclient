require 'webclient'

## more (our own) 3rd party libs
require 'csvreader'


# NEW!! - require/add cocos
require 'cocos'   # - note - cococs incl. webclient & cvsreader  !!!!


## our own code
require_relative 'webget/version'   # let version go first
require_relative 'webget/webcache'
require_relative 'webget/webget'




############
## add convenience alias for camel case / alternate different spelling
WebCache  = Webcache
WebGet    = Webget

## use Webgo as (alias) name (keep reserver for now) - why? why not?
WebGo    = Webget
Webgo    = Webget


puts Webget.banner   # say hello
