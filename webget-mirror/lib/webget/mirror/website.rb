
class Webget
  class Mirror


class Website
  def host
     raise ArgumentError, "website.base_url not set"   if @base_url.nil?
     @base_url.host
  end

  def base_url=( url )
      @base_url = URI( url )   ## note URI() same as URI.parse()
  end
  def base_url
      raise ArgumentError, "website.base_url not set"   if @base_url.nil?
      @base_url.to_s     ## note - returns string NOT uri object!!!
  end



  ## array of hash (table) records e.g.
  ##    page,         encoding
  ##    /index.html,  windows-1252
  def start_pages=( config )
    @start_pages = config
  end
  def start_pages
      raise ArgumentError, "website.start_pages not set"   if @start_pages.nil?
      @start_pages
  end


  def start_pages_path
      ## collect/build path for all start pages
      ## e.g.  path: ['/curdom.html',
      ##               '/curtour.html',
      ##               '/histdom.html',
      ##               '/intclub.html',
      ##               '/intland.html']
      path = []
      start_pages.each do |config|
          path << config['page']
      end
      path
  end
  alias_method :start_path, :start_pages_path


  ###
  ## give preference on schedule next page batch
  ##          if path matches sql like term/str
  ##           e.g.  '/table%'
  ##   => Page.where( 'path LIKE ?', '/table%' )
  ##
    ## note - sql (like) wildcard rules/syntax:
       ##      %: Matches zero or more characters
       ##      _: Matches exactly one character


  def boost_pages_path_like=(str)  @boost = str; end
  def boost_pages_path_like?() defined?( @boost ); end
  def boost_pages_path_like()  defined?( @boost ) ? @boost : nil; end

  alias_method :boost_path_like=, :boost_pages_path_like=
  alias_method :boost_path_like?, :boost_pages_path_like?
  alias_method :boost_path_like,  :boost_pages_path_like





  def default_page_encoding=( encoding )
       @default_page_encoding = encoding
  end
  def _default_page_encoding
       defined?( @default_page_encoding ) ?  @default_page_encoding : 'UTF-8'
  end

  ##
  ##   use hash with custom (individual) defaults e.g.
  ##    Hash.new { |h,key| h[key] = 'windows-1252'  }
  ##
  def page_encodings=( encodings )  ## hash (path => encoding)
      @page_encodings = encodings
  end

  ## default page encoding (lookup by path);
  ##    change to windows-1256 if needed
  def page_encoding( path )
     if defined?( @page_encodings )
        @page_encodings[ path ]
     else
       _default_page_encoding
     end
  end



  def errata_edits=(edits)  @errata_edits = edits; end

  ### quick fix html w/ search & replace
  ##    default: do nothing
  def errata?()   defined?( @errata_edits ); end
  def errata( html, url: )
       if defined?( @errata_edits )

         ## lookup edits by path e.g. /tablesp/poland-satrip77.html
         ##                       or  /miscellaneous/torre-madrid.html

         page_url = URI( url )

         edits = @errata_edits[page_url.path]

         ## note - for now always use gsub (not sub)
         ##   maybe add option later
         if edits
           edits.each do |search,replace|
                         html = html.gsub( search, replace )
                      end
         end
         html
       else   ## pass along as is (1:1)
         html
       end
  end


  def autofix_href=( m )
       raise ArgumentError,
               "proc expected for autofix_href=; got #{m} #{m.class.name}"   unless m.is_a?( Proc )

       @autofix_href = m
  end
  def autofix_href()  defined?( @autofix_href ) ? @autofix_href : nil; end



  ### kick-off mirror (pages) operation/run
  def mirror


    ## add seed/start pages
    start_pages.each do |config|
      path     = config['page']
      encoding = config['encoding']
      encoding = page_encoding( path )   if config['encoding'].nil? || config['encoding'].empty?

      page_rec = MirrorDb::Model::Page.find_or_create_by!( path: path ) do |rec|
                      ## note - block only called on create (NOT find!!)
                      puts "  add page #{rec.path} (cached: false) to mirror.db"

                      rec.encoding = encoding
                      rec.cached   = false
                end
      pp page_rec



      ## fix-fix-fix use Mirror.new( self )
      ##         pass in site config on new!!!
      mirror = Mirror.new
      mirror._mirror_pages( site: self )
    end
  end
end  # class Website
end  ## class Mirror
end  ## class Webget




__END__


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
