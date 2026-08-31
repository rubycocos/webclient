
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


   scope  :cached, -> { where( cached: true ) }
   ## find a better name for not cached (was missing)? why? why not?
   scope  :not_cached, -> { where( cached: false ) }

   ## 404 not_found
   scope  :not_found,  -> { where( http_status: 404 ) }


   ## for extname (file extensions)
   ##   note - .html auto incl .htm !!
   scope  :html,  -> { where( extname: ['.html', '.htm']) }
   scope  :pdf,   -> { where( extname: 'pdf') }

   def html?()  extname == '.html' || extname == '.htm';  end
   def pdf?()   extname == '.pdf'; end

   def not_cached?()  !cached?(); end
   def not_found?()  http_status == 404; end


    ### note - path incl. leading slash e.g. /curtour.html
    ##  def url()  "#{Mirror.config.base_url}#{path}"; end
end # class Page



class Link < ActiveRecord::Base
   belongs_to  :from_page, class_name: 'Page',
                           foreign_key: 'from_page_id'
   belongs_to  :to_page,   class_name: 'Page',
                           foreign_key: 'to_page_id'
end # class Link


end   # module Model
end





module MirrorDb
class CreateDb
def up
  ActiveRecord::Schema.define do

####
# pages tables
create_table :pages do |t|
   t.string :path, null: false

   ##  split/break up path  - maybe make it later virtual columns - why? why not?
   ## add basename, dirname, extname  - why? why not?
   t.string :basename, null: false
   t.string :dirname,  null: false
   t.string :extname,  null: false    ##  note - empty string if no extname?
                                      ##    if present starts with dot (.) e.g.
                                      ##          .html, .pdf, etc.
                                      ##   keep dot why? why not?

   t.string :title          ##   html <title></title>
   t.date   :updated        ## iso date e.g. (2026-04-29) via web page source

   ### add (charset) encoding stuff
   t.string :encoding           ## "upstream" text encoding - all pages converted to utf-8 ALWAYS
   t.boolean :ascii7bit    ## check if all chars are ascii 7bit (utf8-compatible) ??
   t.integer :tabs         ## count tabs/tabstops in html source (use tab or tabs ??)


   t.string  :html_doctype
   t.string  :html_charset

   t.string  :http_content_type     ## http content-type   header
   t.integer :http_content_length   ## http content-length header
   t.integer :http_status           ## e.g. 200, 404  - make mandatory - why? why not?

   ## or use download or date (fetched) or such??
   t.boolean :cached,   default: false

  # t.timestamps  ## (auto)add - why? why not?
  #  do NOT use; save space for now - auto-generated db is read-only
end
add_index :pages, :path, unique: true


## join table  - no need for own ids
create_table :links, id: false do |t|
   t.integer  :from_page_id,  null: false
   t.integer  :to_page_id,    null: false
end
add_index :links, [:from_page_id, :to_page_id], unique: true
add_index :links, :from_page_id
add_index :links, :to_page_id

##
## add errors or log or such - why? why not?
##
  end  # Schema.define
end # method up
end # class CreateDb
end # module MirrorDb




module MirrorDb

=begin
    def self.open_readonly( path='./mirror.db' )

       ### raise ArgumentError, "sqlite db #{path} not found"  if !File.exist?( path )


      config = {
          adapter:  'sqlite3',
          database: path,
          readonly: true,   ## try readonly prop!!!
      }

      ActiveRecord::Base.establish_connection( config )
      # ActiveRecord::Base.logger = Logger.new( STDOUT )

        ## try to speed up sqlite
        ##   see http://www.sqlite.org/pragma.html
        con = ActiveRecord::Base.connection

        ## add for read-only - why? why not?
       # con.execute( 'PRAGMA query_only=ON;' )

       # con.execute( 'PRAGMA synchronous=OFF;' )
       # con.execute( 'PRAGMA journal_mode=OFF;' )
       # con.execute( 'PRAGMA temp_store=MEMORY;' )
    end
=end



    def self.open( path='./mirror.db' )

      ### reuse connect here !!!
      ###   why? why not?

      config = {
          adapter:  'sqlite3',
          database: path,
      }

      ActiveRecord::Base.establish_connection( config )
      # ActiveRecord::Base.logger = Logger.new( STDOUT )

        ## try to speed up sqlite
        ##   see http://www.sqlite.org/pragma.html
        con = ActiveRecord::Base.connection
        con.execute( 'PRAGMA synchronous=OFF;' )
        con.execute( 'PRAGMA journal_mode=OFF;' )
        con.execute( 'PRAGMA temp_store=MEMORY;' )

      ##########################
      ### auto_migrate
      unless Model::Page.table_exists?
          CreateDb.new.up
      end
    end  # method open
end
