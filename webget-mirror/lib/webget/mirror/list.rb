
def dump_page( page, backlinks: false )
   print "%-38s" % page.path

   if page.cached?
      if page.http_status == 404
         print " 404 NOT FOUND"
      else
         print " CACHED"
         print "  %3d" % page.linked_pages.count
      end
   else
      print "       "
      print "     "
   end
   print " / %3d" % page.backlink_pages.count

   if page.encoding != 'windows-1252'
     print "  %-10s" % "(#{page.encoding})"
   else
     print "            "
   end

   print "  >#{page.title}<"   if page.title
   print "\n"

   ### print backlink pages
   if backlinks
       page.backlink_pages.each do |backlink|
           print "                                              <= #{backlink.path}  "
           print "  >#{backlink.title}<"   if backlink.title
           print "\n"
       end
   end
end
