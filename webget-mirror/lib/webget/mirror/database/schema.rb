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
                                      ##          .html|.htm, .pdf, etc.
                                      ##   keep dot why? why not?

   t.string :title          ##   html <title></title>
   t.date   :updated        ## iso date e.g. (2026-04-29) via web page source

   ################
   ### add (charset) encoding stuff
   t.string  :encoding           ## "upstream" text encoding
                                 ##   all pages ALWAYS converted to utf-8
   t.string  :encoding_source   ## e.g. bom|http|html|user|fallback

   t.boolean :encoding_valid  ## uses  String#encoding_valid?
   t.boolean :ascii7bit       ## uses  String#ascii_only?  check if all chars are ascii 7bit (utf8-compatible) ??
   t.integer :chars_8bit       ## count of 8bit (126-255) chars - nil|0|1|2|etc.
   t.integer :utf8_replace     ## count invalid/replace chars in utf8 - nil|0|1|2
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
