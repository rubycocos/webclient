###
#  to run use:
#
#   $ ruby sandbox/test_db.rb


require_relative 'helper'



MirrorDb.open( "./mirror-test.db" )


include MirrorDb::Model

if Page.count == 0

   page1 = Page.create( path: '/curtour.html', cached: true )
   page2 = Page.create( path: '/tables/at.html' )
   page3 = Page.create( path: '/tables/de.html' )
   page4 = Page.create( path: '/tables/de68.html' )

   Link.create( from_page_id: page1.id,  to_page_id: page2.id )
   Link.create( from_page_id: page1.id,  to_page_id: page3.id )
   Link.create( from_page_id: page3.id,  to_page_id: page4.id )
end


puts "  #{MirrorDb::Model::Page.count} page(s)  " +
         "(#{MirrorDb::Model::Page.cached.count} cached, "+
         "#{MirrorDb::Model::Page.not_cached.count} missing)"
puts "  #{MirrorDb::Model::Link.count} links(s)"

Page.all.each do |page|
   puts
   puts "==> page path: #{page.path} (cached: #{page.cached?})"
   puts "   #{page.outgoing_links.count} outgoing link(s):"
   pp page.outgoing_links
   puts "   #{page.incoming_links.count} incoming link(s):"
   pp page.incoming_links

   puts "  ---"
   puts "   #{page.linked_pages.count} linked (outgoing) page(s):"
   pp page.linked_pages
   pp page.outgoing_paths
   puts "   #{page.backlink_pages.count} backlink (incoming) page(s):"
   pp page.backlink_pages
   pp page.incoming_paths
end


puts
Link.all.each do |link|
   puts "==> link from: #{link.from_page.path}, to: #{link.to_page.path}"
   pp link.from_page
   pp link.to_page
end

puts "sql:"
ActiveRecord::Base.logger = Logger.new( STDOUT )

page = Page.find_by( path: '/curtour.html' )

pp page.linked_pages
pp page.outgoing_paths

puts
puts "---"
pp page.backlink_pages
pp page.incoming_paths


puts "bye"
