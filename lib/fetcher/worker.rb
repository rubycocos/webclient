module Fetcher

  class Worker

    include LogUtils::Logging

### todo/fix:
# remove logger from c'tor
#  use logutils instead

    def initialize( old_logger_do_not_use=nil )
      if old_logger_do_not_use != nil
         puts "*** depreciated API call [Fetcher.initialize] - do NOT pass in logger; no longer required/needed; logger arg will get removed"
      end
    end


    def read( src )
      # return contents (response body) a string
      logger.debug "fetch - copy src: #{src} into string"
      
      response = get_response( src )
      
      # on error return empty string  - check: better return nil- why? why not??
      return ''  if response.nil?

      response.body.dup  # return string copy
    end


    def copy( src, dest )
      logger.debug "fetch - copy src: #{src} to dest: #{dest}"

      response = get_response( src )
      
      # on error return; do NOT copy file; sorry
      return  if response.nil?

      # check for content type; use 'wb' for images
      if response.content_type =~ /image/
        logger.debug '  switching to binary'
        flags = 'wb'
      else
        flags = 'w'
      end
  
      File.open( dest, flags ) do |f|
        f.write( response.body )
      end
    end


## todo: add file protocol 

    def get_response( src )
      uri = URI.parse( src )
  
      # new code: honor proxy env variable HTTP_PROXY
      proxy = ENV['HTTP_PROXY']
      proxy = ENV['http_proxy'] if proxy.nil?   # try possible lower/case env variable (for *nix systems) is this necessary??
    
      if proxy
        proxy = URI.parse( proxy )
        logger.debug "using net http proxy: proxy.host=#{proxy.host}, proxy.port=#{proxy.port}"
        if proxy.user && proxy.password
          logger.debug "  using credentials: proxy.user=#{proxy.user}, proxy.password=****"
        else
          logger.debug "  using no credentials"
        end
      else
        logger.debug "using direct net http access; no proxy configured"
        proxy = OpenStruct.new   # all fields return nil (e.g. proxy.host, etc.)
      end
      
      http_proxy = Net::HTTP::Proxy( proxy.host, proxy.port, proxy.user, proxy.password )

      redirect_limit = 4
      response = nil

      until false
        raise ArgumentError, 'HTTP redirect too deep' if redirect_limit == 0
        redirect_limit -= 1
      
        http = http_proxy.new( uri.host, uri.port )
    
        logger.debug "GET #{uri.request_uri} uri=#{uri}, redirect_limit=#{redirect_limit}"
    
        request    = Net::HTTP::Get.new( uri.request_uri, { 'User-Agent'=> 'slideshow'} )
        if uri.instance_of? URI::HTTPS
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
    
        response   = http.request( request )  
  
        if response.code == '200'
          logger.debug "#{response.code} #{response.message}"
          break
        elsif (response.code == '301' || response.code == '302' || response.code == '303' || response.code == '307' )
          # 301 = moved permanently
          # 302 = found
          # 303 = see other
          # 307 = temporary redirect
          logger.debug "#{response.code} #{response.message} location=#{response.header['location']}"
          newuri = URI.parse( response.header['location'] )
          if newuri.relative?
            logger.debug "url relative; try to make it absolute"
            newuri = uri + response.header['location']
          end
          uri = newuri
        else
          msg = "#{response.code} #{response.message}" 
          puts "*** error: #{msg}"
          return nil  # todo: throw StandardException?  
        end
      end

      logger.debug "  content_type: #{response.content_type}, content_length: #{response.content_length}"

      response # return respone or nil if error
    end # method copy

  end # class Worker

end  # module Fetcher
