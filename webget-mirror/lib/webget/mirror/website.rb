
module Mirror
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





  def mirror_pages

    ## add seed/start pages
    start_pages.each do |config|
      path     = config['page']
      encoding = config['encoding']
      encoding = page_encoding( path )   if config['encoding'].nil? || config['encoding'].empty?

      page_rec = MirrorDb::Model::Page.find_or_create_by!( path: path ) do |rec|
                      ## note - block only called on create (NOT find!!)
                      puts "  add page #{rec.path} (cached: false) to mirror.db"

                      rec.basename = File.basename( rec.path, File.extname( rec.path ))
                      rec.extname  = File.extname( rec.path )
                      rec.dirname  = File.dirname( rec.path )

                      rec.encoding = encoding
                      rec.cached   = false
                end
      pp page_rec

      _mirror_pages( site: self )
    end
  end
end  # class Website
end  ## module Mirror
