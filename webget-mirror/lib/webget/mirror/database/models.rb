
##
# note - use a sqlite database for caching pages and (internal) links
##            use via activerecord machinery / object-relational mapper


module MirrorDb
module Model


class Page < ActiveRecord::Base
   has_many  :outgoing_links,  class_name: 'Link',
                               foreign_key: 'from_page_id',
                               :dependent  => :delete_all  ## :destroy

   ## use outgoing_pages or linked_pages?
   has_many  :linked_pages,  :through => :outgoing_links,
                             :source  => :to_page

   ## backlink (incoming)
   has_many  :incoming_links, class_name: 'Link',
                              foreign_key: 'to_page_id',
                               :dependent  => :delete_all  ## :destroy

   ##  use incoming_pages or backlink_pages?
   has_many  :backlink_pages, :through => :incoming_links,
                              :source  => :from_page


   def outgoing_paths() linked_pages.pluck(:path); end
   def incoming_paths() backlink_pages.pluck(:path); end


   ## find a better name for not cached (was missing)? why? why not?
   ##   cached a.k.a. downloaded to local cache
   scope  :cached,     -> { where( cached: true ) }
   scope  :not_cached, -> { where( cached: false ) }

   ## 404 not_found
   scope  :not_found,  -> { where( http_status: 404 ) }
   ##
   ## add scope  :ok  for 200  - why ? why not?


   ## for extname (file extensions)
   ##   note - .html auto incl .htm !!
   scope  :html,  -> { where( extname: ['.html', '.htm']) }
   scope  :pdf,   -> { where( extname: '.pdf') }

   def html?()      extname == '.html' || extname == '.htm';  end
   def not_html?()  !html?();  end
   def pdf?()       extname == '.pdf'; end


   def not_found?()  http_status == 404; end
   def not_cached?()  !cached?(); end


    ### note - path incl. leading slash e.g. /curtour.html
    ##  def url()  "#{Mirror.config.base_url}#{path}"; end




## tip - Use before_validation instead if needed:
##  If your callback modifies attributes that need to be validated,
## use before_validation instead of before_create.
##  before_create runs after validation passes

   ###  note - use callback to autofill basename,extname, dirname from path
   before_validation :autofill

   ## double check added path
   validate :assert_path

private
   def autofill
      self.basename = File.basename( path, File.extname( path ))   if basename.nil?
      self.extname  = File.extname( path )                         if extname.nil?
      self.dirname  = File.dirname( path )                         if dirname.nil?

      ###
      ##  note -  always downcase extname for now - why? why not?
      ##    possibly .HTM or .HTML (or even .Html or such)
      ##
      ##  maybe latter autofill format or such - why? why not?
      self.extname = extname.downcase       if extname
   end

   def assert_path
         ## assert - double check
          ## make sure url.path does NOT start with // or
          ##                              /// !!
         ##  and does NOT end_with /
         ##
         ##                page_rec.path.include?( %r{/{2,}} ) ||
         ##   fix  http.//  typos!!!
         ##      page_rec.path.match?( %r{\.{2,}} )
         ##   fix ..sources typos ...
         ##    pages
           if  path.start_with?( '//' ) ||
               path.end_with?( '/' )  ||
              !path.start_with?( '/' )  ## note - MUST start with single slash (/)
                errors.add(:path, "broken; starts with // or ends with /")
           end

   end
end # class Page





class Link < ActiveRecord::Base
   belongs_to  :from_page, class_name: 'Page',
                           foreign_key: 'from_page_id'
   belongs_to  :to_page,   class_name: 'Page',
                           foreign_key: 'to_page_id'
end # class Link


end   # module Model
end  # module MirrorDb
