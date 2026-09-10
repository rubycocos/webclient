
class Webget
  class Mirror



class Website
  def base_url=( url )
      @base_url = URI( url )   ## note URI() same as URI.parse()
  end
  def base_url
      raise ArgumentError, "required website.base_url not set"   if @base_url.nil?
      @base_url.to_s     ## note - returns string NOT uri object!!!
                         ##        and string keeps original spelling of host
  end

  def host
     raise ArgumentError, "required website.base_url not set"   if @base_url.nil?
     ## note - get automatically downcased via URI() !!!
     ##            e.g. RSSSF.ORG => rsssf.org
     @base_url.host
  end



  ## array of hash(table) records e.g.
  ##    page,         encoding
  ##    /index.html,  windows-1252
  def start_pages=( config )
    @start_pages = config
  end
  def start_pages
      raise ArgumentError, "required website.start_pages not set"   if @start_pages.nil?
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
          path <<  config['page']
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




  ### maybe support (direct) lookup via Hash(Table) in the future too - why? why not?
  def page_encoding=(m)
     raise ArgumentError,
         "obj w/ respond_to?(:call) expected for page_encoding=; got #{m} #{m.class.name}"   unless m.respond_to?( :call )
     @page_encoding = m
  end

  ## default page encoding (lookup by path);
  ##    change to windows-1256 if needed
  def page_encoding( path )
      ## note - encoding defaults to nil (if nothing set) !!!
     defined?( @page_encoding ) ? @page_encoding.call( path ) : nil
  end



  ### maybe support errata_edits via Hash(Table) in the future too - why? why not?
  def errata=(m)
     raise ArgumentError,
         "obj w/ respond_to?(:call) expected for errata=; got #{m} #{m.class.name}"   unless m.respond_to?( :call )
     @errata = m
  end

  def errata?()  defined?( @errata ); end
  ### quick fix html w/ search & replace
  ##    default: do nothing
  def errata( html, url: )
    defined?( @errata ) ? @errata.call( html, url: url) : html
  end



  ### maybe support (literal) autofixese via Hash(Table) in the future too - why? why not?
  def autofix_href=( m )
       raise ArgumentError,
               "obj w/ respond_to?(:call) expected for autofix_href=; got #{m} #{m.class.name}"   unless m.respond_to?( :call )
       @autofix_href = m
  end

  def autofix_href?() defined?( @autofix_href );  end
  def autofix_href( href )
    defined?( @autofix_href ) ? @autofix_href.call( href ) : href
  end




  ################################
  ### kick-off mirror (pages) operation/run
  def mirror

    ## add seed/start pages
    ##
    ##   note - read_csv (CsvReader) returns "" for empty fields and nil for non-existing fields
    ##           e.g.
    ##         page1, encoding1   =>    ['page1', 'encoding1']
    ##         page2,             =>    ['page2', '']
    ##         page3              =>    ['page3']   -- note: encoding results in nil!!

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
      ## pp page_rec
    end


    ## fix-fix-fix use Mirror.new( self )
    ##         pass in site config on new!!!
    mirror = Mirror.new
    mirror._mirror_pages( site: self )
  end
end  # class Website
end  ## class Mirror
end  ## class Webget
