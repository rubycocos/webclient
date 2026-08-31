
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
    File.open( body_path, 'r:utf-8' ) {|f| f.read }
  end

  def read_json( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = File.open( body_path, 'r:utf-8' ) {|f| f.read }
    data = JSON.parse( txt )
    data
  end

  def read_csv( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    txt = File.open( body_path, 'r:utf-8' ) {|f| f.read }
    data = CsvHash.parse( txt )
    data
  end


  def read_meta( url )
    body_path = "#{Webcache.root}/#{url_to_path( url )}"
    meta_path = "#{body_path}.meta.txt"
    txt = File.open( meta_path, 'r:utf-8' ) {|f| f.read }
    data = Headers.parse( txt )
    data
  end


  ## add more save / put / etc. aliases - why? why not?
  ##  rename to record_html - why? why not?

  ##
  ## fix-fix-fix - change encoding: default to nil
  ##
  ###   fix-fix-fix - remove path option hack!!!
  ##      use config to rewrite url_to_path !!!

  def record( url, response,
              path: nil,
              encoding: 'UTF-8',
              format: 'html' )

    ## todo/check - use rel_path or local_path or such??
    save_path = url_to_path( url, path: path )

    body_path = "#{Webcache.root}/#{save_path}"
    meta_path = "#{body_path}.meta.txt"

    ## make sure path exits
    FileUtils.mkdir_p( File.dirname( body_path ) )


    puts "[cache] saving #{body_path}..."

    ## todo/check: verify content-type - why? why not?
    ## note - for now respone.text always assume (converted) to utf8!!!!!!!!!
    ##
    ## fix: newlines - always use "unix" style" - why? why not?
    ## fix:  use :newline => :universal option? translates to univeral "\n"
    if format == 'json'
      File.open( body_path, 'w:utf-8' ) {|f| f.write( JSON.pretty_generate( response.json )) }
      x_encoding_bom   = nil
      x_encoding       = nil   ## for now do not track; always assume  UTF-8
      x_encoding_valid = nil
      x_ascii_only     = nil
      x_8bit           = nil
    elsif format == 'csv'
      ## fix: newlines - always use "unix" style" - why? why not?
      ## fix:  use :newline => :universal option? translates to univeral "\n"
      text          = response.text( encoding: encoding ).gsub( "\r\n", "\n" )
      File.open( body_path, 'w:utf-8' ) {|f| f.write( text ) }

      ### note - bom if different will overwrite (user) encoding!!!
      x_encoding_bom   = response._text_encoding_bom
      x_encoding       = response._text_encoding
      x_encoding_valid = response._text_encoding_valid  # true|false or nil (undef)
      x_ascii_only     = response._text_ascii_only
      x_8bit           = response._text_8bit
    else   ## html or txt
      text          = response.text( encoding: encoding ).gsub( "\r\n", "\n" )
      File.open( body_path, 'w:utf-8' ) {|f| f.write( text ) }

      ### note - bom if different will overwrite (user) encoding!!!
      x_encoding_bom   = response._text_encoding_bom
      x_encoding       = response._text_encoding
      x_encoding_valid = response._text_encoding_valid  # true|false or nil (undef)
      x_ascii_only     = response._text_ascii_only
      x_8bit           = response._text_8bit
    end


    ### fix-fix-fix  -- add support for binary/image formats
    ##     e.g. bin|gif|jpg|etc  - why? why not?

    ####
    ## get file size in bytes
    ##     or use File.stat( body_path ).size (using File::Stat) ??
    x_size    = File.size( body_path )



    File.open( meta_path, 'w:utf-8' ) do |f|
      ## todo/check:
      ##  do headers also need to converted (like text) if encoding is NOT utf-8 ???


      #### add our own custom headers first!!
      ##     change x-save to x-filename or ??
      ##     change to x-7bit-only or x-ascii7bit or x-ascii7bit-only or ??
      ##     change x-size to x-bytesize or ??
      ##     change x-8bit  to ???

      ### start w/ comment line
      ###   uncomment - http status - why? why not?
      f.write( "# fetched on #{Time.now.utc}\n")
      f.write( "# HTTP/#{response.status.http_version} #{response.status.code} #{response.status.message}\n")
      f.write( "\n" )

      f.write( "x-url: #{url}\n" )
      f.write( "x-encoding-bom: #{x_encoding_bom}\n" )      if x_encoding_bom
      f.write( "x-encoding: #{x_encoding}\n" )              if x_encoding
      f.write( "x-encoding-valid: #{x_encoding_valid}\n" )  if x_encoding_valid
      f.write( "x-ascii-only: #{x_ascii_only}\n" )          if x_ascii_only
      f.write( "x-8bit: #{x_8bit}\n" )                      if x_8bit
      f.write( "x-save: #{save_path}\n" )
      f.write( "x-size: #{x_size}\n")
      f.write( "x-format: #{format}\n" )     ## e.g. json|html|csv|etc.
      f.write( "\n" )


      # iterate all response headers
      response.headers.each do |key, value|
        f.write( "#{key}: #{value}" )
        f.write( "\n" )
      end
    end
  end



  ### note: use file path as id for DiskCache  (is different for DbCache/SqlCache?)
  ##    use file:// instead of disk:// - why? why not?
  ##    def url_to_id( str ) "disk://#{url_to_path( str )}"; end


  ### helpers
  def url_to_path( str, path: nil )
    ## map url to file path
    uri = URI( str )       ## URI() same as URI.parse()

    ## note: ignore scheme (e.g. http/https)
    ##         and  post  (e.g. 80, 8080, etc.) for now
    ##    always downcase for now (internet domain is case insensitive)
    host_dir = uri.host.downcase

    req_path = if path   ## use "custom" (file)path for cache storage if passed in
                 path
               else
                 ## "/this/is/everything?query=params"
                 ##   cut-off leading slash and
                 ##    convert query ? =
                 rewrite_path( host_dir, uri.request_uri[1..-1] )
               end


    page_path = "#{host_dir}/#{req_path}"
    page_path
  end
end # class DiskCache


end  ## module Webcache
