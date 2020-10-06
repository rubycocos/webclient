require 'pp'
require 'time'
require 'date'
require 'fileutils'

require 'uri'
require 'net/http'
require 'net/https'

require 'json'
require 'yaml'


# our own code
require 'webclient/version'   # note: let version always go first
require 'webclient/webclient'


############
## add convenience alias for camel case / alternate different spelling
WebClient = Webclient


# say hello
puts Webclient.banner    if defined?( $RUBYLIBS_DEBUG )
