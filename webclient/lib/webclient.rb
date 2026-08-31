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
require_relative 'webclient/version'   # note: let version always go first

require_relative 'webclient/webclient-get'
require_relative 'webclient/webclient-post'
require_relative 'webclient/webclient_response'


############
## add convenience alias for camel case / alternate different spelling
WebClient = Webclient


# say hello
puts Webclient.banner     ## if defined?( $RUBYLIBS_DEBUG )
