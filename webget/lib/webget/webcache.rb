

module Webcache


  #####
  # copied from props gem, see Env.home
  #    - https://github.com/rubycoco/props/blob/master/props/lib/props/env.rb
  #   todo/fix: use original - and do NOT copy-n-paste!!! - why? why not?
  def self.home
    path = if( ENV['HOME'] || ENV['USERPROFILE'] )
             ENV['HOME'] || ENV['USERPROFILE']
           elsif( ENV['HOMEDRIVE'] && ENV['HOMEPATH'] )
             "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}"
           else
             begin
                File.expand_path('~')
             rescue
                if File::ALT_SEPARATOR
                   'C:/'
                else
                   '/'
                end
             end
           end

    ## note: use File.expand_path to "unify" path e.g
    ##  C:\Users\roman  becomes
    ##  C:/Users/roman
    File.expand_path( path )
 end


 class Configuration
    ## root directory - todo/check: find/use a better name - why? why not?
    def root()       @root || "#{Webcache.home}/.cache"; end
    def root=(path)
       ## note: use File.expand_path to "unify" and auto-expand path
       ##                to make sure always absolute
       ## e.g
       ##  C:\Users\roman  becomes
       ##  C:/Users/roman
        @root = File.expand_path(path)
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
 def self.root()       config.root; end
 def self.root=(path)  config.root = path; end





 ### "interface" for "generic" cache storage (might be sqlite database or filesystem)
 def self.cache() @cache ||= DiskCache.new; end

 def self.record( url, response, format: )  ## html|txt|csv|json|etc.
  ##  note - (text) encoding_user MUST get passed along in response obj/wrapper
  ##            response._encoding_user = encoding! !!
   cache.record( url, response, format: format );
 end

 def self.cached?( url ) cache.cached?( url ); end

 ##  def self.url_to_id( url )  cache.url_to_id( url ); end  ## todo/check: rename to just id or something - why? why not?


 def self.read( url )       cache.read( url );      end
 def self.read_json( url )  cache.read_json( url ); end
 def self.read_csv( url )   cache.read_csv( url );  end


#### new - read (cached) meta data
##    todo/check - find a better/different name - why? why not?
##       e.g. read_headers or simply meta or headers or such
  def self.read_meta( url ) cache.read_meta( url ); end

  ## add convenience expire (shortcut) helpers
  def self.expired?( url, expires_in: Time.now.utc-60*60*12 )
     if cached?( url )
       meta = read_meta( url )
       meta.expired?( expires_in )
     else
       true  # note - not in cache; expired by default
     end
  end
  def self.expired_in_12h?( url ) expired?( url, expires_in: Time.now.utc-60*60*12 ); end
  def self.expired_in_24h?( url ) expired?( url, expires_in: Time.now.utc-60*60*24 ); end


  class << self
    alias_method :exist?,         :cached?
    alias_method :expired_in_1d?, :expired_in_24h?
  end
end  # module Webcache
