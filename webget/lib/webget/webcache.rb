

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
    def root=(value) @root = value; end
 end # class Configuration


 ## lets you use
 ##   Webcache.configure do |config|
 ##      config.root = './cache'
 ##   end
 def self.configure() yield( config ); end
 def self.config()    @config ||= Configuration.new;  end


 ## add "high level" root convenience helpers
 def self.root()       config.root; end
 def self.root=(value) config.root = value; end


 ### "interface" for "generic" cache storage (might be sqlite database or filesystem)
 def self.cache() @cache ||= DiskCache.new; end

 def self.record( url, response,
                   path: nil,
                   encoding: 'UTF-8',
                   format: 'html' )
   cache.record( url, response,
                   path: path,
                   encoding: encoding,
                   format: format );
 end
 def self.cached?( url ) cache.cached?( url ); end
 class << self
   alias_method :exist?, :cached?
 end
 def self.url_to_id( url )  cache.url_to_id( url ); end  ## todo/check: rename to just id or something - why? why not?
 def self.read( url )       cache.read( url );      end
 def self.read_json( url )  cache.read_json( url ); end
 def self.read_csv( url )   cache.read_csv( url );  end



class DiskCache
  def cached?( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    File.exist?( body_path )
  end
  alias_method :exist?, :cached?


  def read( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    File.open( body_path, 'r:utf-8' ) {|f| f.read }
  end

  def read_json( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = File.open( body_path, 'r:utf-8' ) {|f| f.read }
    data = JSON.parse( txt )
    data
  end

  def read_csv( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = File.open( body_path, 'r:utf-8' ) {|f| f.read }
    data = CsvHash.parse( txt )
    data
  end


  ## add more save / put / etc. aliases - why? why not?
  ##  rename to record_html - why? why not?
  def record( url, response,
              path: nil,
              encoding: 'UTF-8',
              format: 'html' )

    body_path = "#{Webcache.root}/#{url_to_path( url, path: path )}"
    meta_path = "#{body_path}.meta.txt"

    ## make sure path exits
    FileUtils.mkdir_p( File.dirname( body_path ) )


    puts "[cache] saving #{body_path}..."

    ## todo/check: verify content-type - why? why not?
    ## note - for now respone.text always assume (converted) to utf8!!!!!!!!!
    if format == 'json'
      File.open( body_path, 'w:utf-8' ) {|f| f.write( JSON.pretty_generate( response.json )) }
    elsif format == 'csv'
      ## fix: newlines - always use "unix" style" - why? why not?
      ## fix:  use :newline => :universal option? translates to univeral "\n"
      text = response.text( encoding: encoding ).gsub( "\r\n", "\n" )
      File.open( body_path, 'w:utf-8' ) {|f| f.write( text ) }
    else   ## html or txt
      text = response.text( encoding: encoding )
      File.open( body_path, 'w:utf-8' ) {|f| f.write( text ) }
    end


    File.open( meta_path, 'w:utf-8' ) do |f|
      ## todo/check:
      ##  do headers also need to converted (like text) if encoding is NOT utf-8 ???
      response.headers.each do |key, value|  # iterate all response headers
        f.write( "#{key}: #{value}" )
        f.write( "\n" )
      end
    end
  end



  ### note: use file path as id for DiskCache  (is different for DbCache/SqlCache?)
  ##    use file:// instead of disk:// - why? why not?
  def url_to_id( str ) "disk://#{url_to_path( str )}"; end


  ### helpers
  def url_to_path( str, path: nil )
    ## map url to file path
    uri = URI.parse( str )

    ## note: ignore scheme (e.g. http/https)
    ##         and  post  (e.g. 80, 8080, etc.) for now
    ##    always downcase for now (internet domain is case insensitive)
    host_dir = uri.host.downcase

    req_path = if path   ## use "custom" (file)path for cache storage if passed in
                 path
               else
                ## "/this/is/everything?query=params"
                ##   cut-off leading slash and
                ##    convert query ? =
                 uri.request_uri[1..-1]
               end



    ### special "prettify" rule for weltfussball
    ##   /eng-league-one-2019-2020/  => /eng-league-one-2019-2020.html
    if host_dir.index( 'weltfussball.de' ) ||
       host_dir.index( 'worldfootball.net' )
          if req_path.end_with?( '/' )
             req_path = "#{req_path[0..-2]}.html"
          else
            puts "ERROR: expected request_uri for >#{host_dir}< ending with '/'; got: >#{req_path}<"
            exit 1
          end
    elsif host_dir.index( 'tipp3.at' )
      req_path = req_path.sub( '.jsp', '' )  # shorten - cut off .jsp extension

      ##   change ? to -I-
      ##   change = to ~
      ##   Example:
      ##   sportwetten/classicresults.jsp?oddsetProgramID=888
      ##     =>
      ##   sportwetten/classicresults-I-oddsetProgramID~888
      req_path = req_path.gsub( '?', '-I-' )
                         .gsub( '=', '~')

      req_path = "#{req_path}.html"
    elsif host_dir.index( 'fbref.com' )
      req_path = req_path.sub( 'en/', '' )      # shorten - cut off en/
      req_path = "#{req_path}.html"             # auto-add html extension
    elsif host_dir.index( 'football-data.co.uk' )
      req_path = req_path.sub( 'mmz4281/', '' )  # shorten - cut off mmz4281/
      req_path = req_path.sub( 'new/', '' )      # shorten - cut off new/
    elsif host_dir.index( 'football-data.org' )
      req_path = req_path.sub( 'v2/', '' )  # shorten - cut off v2/

      ## flattern - make a file path - for auto-save
      ##   change ? to -I-
      ##   change / to ~~
      ##   change = to ~
      req_path = req_path.gsub( '?', '-I-' )
                         .gsub( '/', '~~' )
                         .gsub( '=', '~')

      req_path = "#{req_path}.json"
    elsif host_dir.index( 'api.cryptokitties.co' )
      ## for now always auto-add .json extensions e.g.
      ##     kitties/1   => kitties/1.json
      ##     cattributes => cattributes.json
      req_path = "#{req_path}.json"
    else
      ## no special rule
    end

    page_path = "#{host_dir}/#{req_path}"
    page_path
  end
end # class DiskCache


end  # module Webcache
