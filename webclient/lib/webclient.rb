###
## note - requires basicially a mirror/clone of cococs "prelude/prolog"
##           see <https://github.com/rubycocos/cocos/blob/master/lib/cocos.rb>

require 'pp'
require 'time'
require 'date'
require 'fileutils'
require 'pathname'   ### auto-add for use of relative_path construction
require 'base64'     ### ## e.g. Base64.decode64,Base64.encode64,...

require 'uri'
require 'net/http'
require 'net/https'
require 'cgi'        ## auto-add  for use of params encoding

require 'json'
require 'yaml'



# our own code
require_relative 'webclient/version'   # note: let version always go first

require_relative 'webclient/webclient-get'
require_relative 'webclient/webclient-post'
require_relative 'webclient/webclient_response'
require_relative 'webclient/webclient_response-status'
require_relative 'webclient/webclient_response-text'


############
## add convenience alias for camel case / alternate different spelling
WebClient = Webclient


# say hello
puts Webclient.banner     ## if defined?( $RUBYLIBS_DEBUG )
