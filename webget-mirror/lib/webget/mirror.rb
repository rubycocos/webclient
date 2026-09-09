$LOAD_PATH.unshift( '/sports/rubycocos/webclient/webclient/lib' )
$LOAD_PATH.unshift( '/sports/rubycocos/webclient/webget/lib' )


require 'cocos'
require 'webget'           ## incl. webget, webcache, webclient, etc.
require 'nokogiri'

require 'active_record'   ## todo: add sqlite3? etc.


### our own
require_relative 'mirror/version'     ## version first

require_relative 'mirror/database/schema'
require_relative 'mirror/database/models'
require_relative 'mirror/database/open'




require_relative 'mirror/download_page'
require_relative 'mirror/find_links'  ## find_links helper 'n' more
require_relative 'mirror/collect_page_info'


require_relative 'mirror/mirror'


require_relative 'mirror/utils'
require_relative 'mirror/website'



class Webget
  class Mirror

## auto log errors  (append to logs.txt)
def log( msg )
   ## append msg to ./logs.txt
   ##     use ./errors.txt - why? why not?
   File.open( './mirror_logs.txt', 'a:utf-8' ) do |f|
     f.write( msg )
     f.write( "\n" )
   end
end

end  ## class Mirror
end  ## class Webget





puts Webget::Mirror.banner    ## say hello
