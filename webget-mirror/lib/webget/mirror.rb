$LOAD_PATH.unshift( '/sports/rubycocos/webclient/webclient/lib' )
$LOAD_PATH.unshift( '/sports/rubycocos/webclient/webget/lib' )


require 'cocos'
require 'webget'           ## incl. webget, webcache, webclient, etc.
require 'nokogiri'

require 'active_record'   ## todo: add sqlite3? etc.



=begin
module Mirror
  class Configuration
     def host() @base_url.host; end

     def base_url
        raise ArgumentError, "config.base_url not set"   if @base_url.nil?
        @base_url
     end
     def base_url=( url )
        @base_url = URI( url )   ## note URI() same as URI.parse()
     end
  end # class Configuration


 ## lets you use
 ##   Webcache.configure do |config|
 ##      config.root = './cache'
 ##   end
 def self.configure() yield( config ); end
 def self.config()    @config ||= Configuration.new;  end


 ## add "high level" root convenience helpers
 ##   use delegate helper - why? why not?
 ## def self.host()       config.host; end
 ## def self.host=(value) config.host = value; end
end   # module Mirror
=end


require_relative 'mirror/database/schema'
require_relative 'mirror/database/models'
require_relative 'mirror/database/open'




require_relative 'mirror/download_page'
require_relative 'mirror/find_links'  ## find_links helper 'n' more
require_relative 'mirror/collect_page_info'


require_relative 'mirror/mirror'


require_relative 'mirror/utils'
require_relative 'mirror/website'



## auto log errors  (append to logs.txt)
def log( msg )
   ## append msg to ./logs.txt
   ##     use ./errors.txt - why? why not?
   File.open( './mirror_logs.txt', 'a:utf-8' ) do |f|
     f.write( msg )
     f.write( "\n" )
   end
end
