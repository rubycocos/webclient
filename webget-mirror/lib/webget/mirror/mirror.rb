
## use recursive_download_page or such - why? why not?
##   or add recursive flag

=begin
visited: 100 (downloaded: 98) -  35586 page(s) indexed (9158 cached, 26428 missing)
    [98/26526 -  0.00%]  2:14 mins -  1.38 secs/page, estimate: 608:53 mins
=end



##
##  use limit for batch - why? why not?
##     start of / try a batch of a hundred
def _mirror_pages( site:,
                   force: false,
                   batch: 1000 )

    visited    = 0
    downloaded = 0

    time_start = Time.now

    loop do

       ## (i)  prioritize main pages (e.g. use start_pages_path)
       ## /curdom.html
       ## /curtour.html
       ## /histdom.html
       ## /intclub.html
       ## /intland.html
      page_recs =  MirrorDb::Model::Page.where( cached: false,
                                                path:   site.start_pages_path
                                               ).limit( batch )


      ##  (ii)   prefer pages   (e.g. use boost_pages_path_like)
      ##  starting with /tables,/tables[a-z]/
      if page_recs.size == 0 && site.boost_pages_path_like?
        page_recs =  MirrorDb::Model::Page.where( cached: false ).
                                           where( 'path LIKE ?',
                                                  site.boost_pages_path_like ).limit( batch )
      end

      ##  (iii)  retry "unconstrained"  if nothing found matching  (i & ii)
      if page_recs.size == 0
        page_recs =  MirrorDb::Model::Page.where( cached: false ).limit( batch )
      end


      ### no more pages - done - break out of loop and say goodbye
      break   if page_recs.size == 0




       page_recs.each_with_index do |page_rec,i|

        ##
        ##  fix-fix-fix  - change to mime type - why? why not?
        ##           allow pages with no extensions!!!

         ### special case for non .html/.htm pages (e.g. .pdf others too??)
         ##    do NOT download / mirror / cache for now
         if page_rec.not_html?
            page_rec.update!( cached: true )
            next
         end


         ## note - on download (not if cached)
         ##        encoding
         ##           might be get changed
         ##        ALWAYS use updated encoding!!

         ##
         ## note - workaround for windows
         ##     on windows File.exist? (and Webcache.cached?)
         ##          is case-insensitive
         ##    e.g. /USAdave/ is the same as /usadave/
         ##
         ##   as a workaround ALWAYS hardcode 404
         ##    for /USAdave/    to get (and record) 404  (and not CACHE HITS!!)
         ##   e.g. try https://rsssf.org/USAdave/cncc.html  => 404 (NOT FOUND)
         ##            https://rsssf.org/usadave/cncc.html  => 200 (OK)


         ##  note - url e.g. https://rsssf.org
         ##         path MUST start with /  e.g.  /curtour.html
         ##  resulting in   https://rsssf.org/curtour.html

         url = site.base_url+page_rec.path

        ## if %r{/USAdave/}.match?(page_rec.path)
        ##                                 ['', {status: 404}]



  ## check if not in cache
  ##   note - use force == true  to always (force) download

          html, response_meta = _download_page( url,
                                                encoding: page_rec.encoding,
                                                force:    force  )

          if response_meta
              downloaded += 1
              puts " ---  " + fmt_time_diff( time_start,  count: downloaded )

              ###
              ## special case
              ##  check for 404 NOT FOUND
              if response_meta[:http_status] == 404
                      page_rec.update!( http_status: 404,
                                        cached:      true )

                next   ### note - skip further processing on 404 (no links etc.)!!
              end
          end



          html = site.errata( html, url: url )    if site.errata?




         ## Standard HTML4-style parsing (default)
         ## doc = Nokogiri::HTML(malformed_html)
         ##  -or-
         ## More robust HTML5 parsing
         ##doc = Nokogiri::HTML5(malformed_html)

           doc = Nokogiri::HTML( html )


           ## get (page meta info)
           ##   title, tabs (count), html_doctype, html_charset
            page_info = _collect_page_info( doc, html: html )



          ##  note - if response meta data present than fresh download (not cached)
          ##  cached  = response_meta ? false : true

          ## turn on verbose mode only if page downloaded (not on cache hit)
           verbose = response_meta ? true : false
          ## verbose = true

           internals, _ = _find_links( site: site,
                                       doc: doc,
                                       url: url,
                                       verbose: verbose
                                     )


            ## add links to db
            internals.each do |path|
               internal_rec = MirrorDb::Model::Page.find_or_create_by!(
                                                            path: path ) do |rec|
                                    puts "     add linked page #{rec.path}"

                                    rec.encoding = site.page_encoding( rec.path )
                                    rec.cached   = false
                                 end

               ## puts "  add link from #{page_rec.path} to #{internal_rec.path} to mirror.db"
               ###  note allow - find (may happen after "crash" or interrupt)
               link_rec = MirrorDb::Model::Link.find_or_create_by!(
                                                         from_page_id: page_rec.id,
                                                         to_page_id:   internal_rec.id )
            end

            puts "  [#{i+1}/#{page_recs.size}] update page #{page_rec.path} w/ #{internals.size} page(s) linked - >#{page_info[:title] || 'n/a'}<"


            ###
            ##  note - remove cached (flag) and replace with http_status => nil|200|404|etc?
            ##         that is, cached = false  => nil
            ##                  cached = true   =>  200|404|etc - why? why not??
            attribs = {
                cached: true
            }
            ## add (optional) page_info attribus
            more_attribs = {
              title:        page_info[:title], ## note - might be missing (nil) in some pages
              html_doctype: page_info[:html_doctype],
              html_charset: page_info[:html_charset],
              tabs:         page_info[:tabs]
            }
            attribs = attribs.merge( more_attribs )


            ## check for encoding when fresh download (via response meta data)
            if response_meta
               more_attribs = {
                  encoding:        response_meta[:encoding] ? response_meta[:encoding].downcase : nil,
                  encoding_source: response_meta[:encoding_source],   ## bom|html|http|user|fallback
                  encoding_valid:  response_meta[:encoding_valid],    ## nil|true|false

                   ascii7bit:         response_meta[:ascii7bit],      ## nil|true|false
                   ## note - convert 10 - 212=>8, 233=>2  (use only first total count; no details)
                   chars_8bit:        response_meta[:chars_8bit] ? response_meta[:chars_8bit].to_i(10) : nil,
                   utf8_replace:      response_meta[:utf8_replace],

                   http_content_type:     response_meta[:http_content_type],
                   http_content_length:   response_meta[:http_content_length],
                   http_status:           response_meta[:http_status]
                }
               attribs = attribs.merge( more_attribs )
            end


            page_rec.update!( **attribs )



            visited += 1

           if visited % 100 == 0
              puts "\n visited: #{visited} (downloaded: #{downloaded}) - " +
                 " #{MirrorDb::Model::Page.count} page(s) indexed " +
                 "(#{MirrorDb::Model::Page.cached.count} cached, " +
                 "#{MirrorDb::Model::Page.not_cached.count} missing)"

             puts "  " + fmt_time_diff( time_start,  step: downloaded,
                                                      count: downloaded+MirrorDb::Model::Page.not_cached.count )


           end
       end
    end



            puts "\n visited: #{visited} (downloaded: #{downloaded}) - " +
                 " #{MirrorDb::Model::Page.count} page(s) indexed " +
                 "(#{MirrorDb::Model::Page.cached.count} cached, " +
                 "#{MirrorDb::Model::Page.not_cached.count} missing)"
end
