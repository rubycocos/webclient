
module Webcache


class DiskCache     ### todo/check - change to Disk - why? why not?



  def cached?( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    exist =  File.exist?( body_path )

=begin
##  not really working - check back later
###   The catch on Windows
##   On Windows, File.realpath does NOT normalize casing to the on-disk canonical case.
##
## note - on windows - file.exist? is case-insensitive
##         use the strict: true flag if you want to enforce case-sensitive exists checks on windows!!!
##   On Windows, File.realpath returns the "true" path
##    as stored on the disk with the correct casing.
##    If the path you provide doesn't match the casing of the real path,
##     you know the match was case-insensitive.
    if exist && strict
     exist =  File.realpath(body_path) == File.expand_path(body_path)
    end
=end

    exist
  end
  alias_method :exist?, :cached?



  ### fix-fix-fix
  ##    change to read_txt/read_text/read_html
  ##  plus add
  ##     read_blob/read_bin !!!
  def read( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    _read_utf8( body_path )
  end

  def read_json( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = _read_utf8( body_path )
    data = JSON.parse( txt )
    data
  end

  def read_csv( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = _read_utf8( body_path )
    data = CsvHash.parse( txt )
    data
  end


  def read_meta( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    meta_path = "#{body_path}.meta.txt"
    txt = _read_utf8( meta_path )
    data = Headers.parse( txt )
    data
  end




  ## add more save / put / etc. aliases - why? why not?
  ##  rename to record_html - why? why not?

  def record( url, response, format: )

    ###
    ## note - encoding_user MUST be passed along with response (wrapper) obj
    ##           e.g.  response._encoding_user = encoding ??
    ##                   see Webget.page|text|dataset|etc.


    ## todo/check - use rel_path or local_path or such??
    save_path = url_to_path( url )

    body_path = "#{Webcache.root}/#{save_path}"
    meta_path = "#{body_path}.meta.txt"

    ## make sure path exits
    FileUtils.mkdir_p( File.dirname( body_path ) )


    puts "[cache] saving #{body_path}..."

    ## todo/check: verify content-type - why? why not?
    ## note - for now respone.text always assume (converted) to utf8!!!!!!!!!

    if format == 'json'
      _write_utf8( body_path, JSON.pretty_generate( response.json ))
      x_encoding        = nil   ## for now do not track; always assume  UTF-8
      x_encoding_source = nil
      x_encoding_valid  = nil
      x_ascii_only      = nil
      x_8bit            = nil
      x_utf8_replace    = nil
    else   ## html,  txt or csv
      _write_utf8( body_path, response.text )

      x_encoding        = response._text_encoding
      x_encoding_source = response._text_encoding_source
      x_encoding_valid  = response._text_encoding_valid  # true|false or nil (undef)
      x_ascii_only      = response._text_ascii_only
      x_8bit            = response._text_8bit
      x_utf8_replace    = response._text_utf8_replace
    end


    ### fix-fix-fix  -- add support for binary/image formats
    ##     e.g. bin|gif|jpg|etc  - why? why not?

    ####
    ## get file size in bytes
    ##     or use File.stat( body_path ).size (using File::Stat) ??
    x_size    = File.size( body_path )



      ## todo/check:
      ##  do headers also need to converted (like text) if encoding is NOT utf-8 ???


      #### add our own custom headers first!!
      ##     change x-save to x-filename or ??
      ##     change to x-7bit-only or x-ascii7bit or x-ascii7bit-only or ??
      ##     change x-size to x-bytesize or ??
      ##     change x-8bit  to ???

      ### start w/ comment line
      ###   uncomment - http status - why? why not?
      buf = String.new
      buf << "# fetched on #{Time.now.utc}\n"
      buf << "# HTTP/#{response.version} #{response.status.code} #{response.status.message}\n"
      buf << "\n"

      buf << "x-url: #{url}\n"
      buf << "x-encoding: #{x_encoding}\n"                 if x_encoding
      buf << "x-encoding-source: #{x_encoding_source}\n"   if x_encoding_source
      buf << "x-encoding-valid: #{x_encoding_valid}\n"     if x_encoding_valid
      buf << "x-ascii-only: #{x_ascii_only}\n"             if x_ascii_only
      buf << "x-8bit: #{x_8bit}\n"                         if x_8bit
      buf << "x-utf8-replace: #{x_utf8_replace}\n"         if x_utf8_replace
      buf << "x-save: #{save_path}\n"
      buf << "x-size: #{x_size}\n"
      buf << "x-format: #{format}\n"      ## e.g. json|html|csv|etc.
      buf << "\n"

      # iterate all response headers
      response.headers.each do |key, value|
        buf << "#{key}: #{value}\n"
      end

      _write_utf8( meta_path, buf )
  end



  ### note: use file path as id for DiskCache  (is different for DbCache/SqlCache?)
  ##    use file:// instead of disk:// - why? why not?
  ##    def url_to_id( str ) "disk://#{url_to_path( str )}"; end


  ### helpers
  def url_to_path( str )
    ## map url to file path
    uri = URI( str )       ## URI() same as URI.parse()

    ## note: ignore scheme (e.g. http/https)
    ##         and  post  (e.g. 80, 8080, etc.) for now
    ##    always downcase for now (internet domain is case insensitive)
    host_dir = uri.host.downcase

    ## "/this/is/everything?query=params"
    ##   cut-off leading slash and
    ##    convert query ? =
    req_path =   rewrite_path( host_dir, uri.request_uri[1..-1] )


    page_path = "#{host_dir}/#{req_path}"
    page_path
  end


  def _read_utf8( path )
    File.open( path, 'r:utf-8' ) {|f| f.read }
  end

  def _write_utf8( path, text )
     ##  write out utf8 (always use "universal" newlines on any platform)
     ##    todo / fix -   add  universial or such to open too ??
     ##
     ## fix: newlines - always use "unix" style" - why? why not?
     ## fix:  use :newline => :universal option? translates to univeral "\n"

    text  = text.gsub( "\r\n", "\n" )
    File.open( path, 'w:utf-8' ) {|f| f.write( text ) }
  end
end # class DiskCache


end  ## module Webcache
