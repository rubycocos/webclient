
module Webcache
class DiskCache

####
##  todo/fix - make rewrite_path configurable "pipeline"
##          lets you auto-add more rewriters
##         and keep this code "generic"
##    move rewriters "downstream" into "userland" ??

def rewrite_path( host, req_path )

        ### special "prettify" rule for weltfussball
    ##   /eng-league-one-2019-2020/  => /eng-league-one-2019-2020.html

    ### todo/fix - move rules downstream to user - why? why not?

    if host.include?( 'uefa.com' ) ||
       host.include?( 'kicker.de' ) ||
       host.include?( 'kicker.at' )
      if req_path.end_with?( '/' )
        req_path = "#{req_path[0..-2]}.html"
      else
        puts "ERROR: expected request_uri for >#{host}< ending with '/'; got: >#{req_path}<"
        exit 1
      end
    elsif host.include?( 'weltfussball.de' ) ||
          host.include?( 'worldfootball.net' )
          if req_path.end_with?( '/' )
             req_path = "#{req_path[0..-2]}.html"
          else
            puts "ERROR: expected request_uri for >#{host}< ending with '/'; got: >#{req_path}<"
            exit 1
          end
    elsif host.include?( 'tipp3.at' )
      req_path = req_path.sub( '.jsp', '' )  # shorten - cut off .jsp extension

      ##   change ? to -I-
      ##   change = to ~
      ##   Example:
      ##   sportwetten/classicresults.jsp?oddsetProgramID=888
      ##     =>
      ##   sportwetten/classicresults-I-oddsetProgramID~888
      req_path = req_path.gsub( '?', '-I-' )
                         .gsub( '=', '~')

      req_path = "#{req_path}.html"
    elsif host.include?( 'fbref.com' )
      req_path = req_path.sub( 'en/', '' )      # shorten - cut off en/
      req_path = "#{req_path}.html"             # auto-add html extension
    elsif host.include?( 'football-data.co.uk' )
      req_path = req_path.sub( 'mmz4281/', '' )  # shorten - cut off mmz4281/
      req_path = req_path.sub( 'new/', '' )      # shorten - cut off new/
    elsif host.include?( 'football-data.org' )
      ##  req_path = req_path.sub( 'v2/', '' )  # shorten - cut off v2/

      ## flattern - make a file path - for auto-save
      ##   change ? to -I-
      ##   change / to ~~
      ##   change = to ~
      req_path = req_path.gsub( '?', '-I-' )
                         .gsub( '/', '~~' )
                         .gsub( '=', '~')

      req_path = "#{req_path}.json"
    elsif host.include?( 'api-sports.io' )
      req_path = req_path.gsub( '?', '-I-' )
                         .gsub( '&', '~~' )   ### check if & present?
                         .gsub( '=', '~')

      req_path = "#{req_path}.json"
    elsif host.include?( 'api.cryptokitties.co' )
      ## for now always auto-add .json extensions e.g.
      ##     kitties/1   => kitties/1.json
      ##     cattributes => cattributes.json
      req_path = "#{req_path}.json"
    else
      ## no special rule
    end

    req_path
end  # method rewrite_path


end  # class DiskCache
end # module Webcache
