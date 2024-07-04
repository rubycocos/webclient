
class Webget   # a web (go get) crawler

  class Configuration  ## nested class
    #######################
    ## accessors
    def sleep()       @sleep || 3; end     ### todo/check: use delay / wait or such?
    def sleep=(value) @sleep = value; end
    ## add delay, delay_in_s alias - why? why not?
    alias_method :delay,       :sleep
    alias_method :delay_in_s,  :sleep
    alias_method :delay=,      :sleep=
    alias_method :delay_in_s=, :sleep=
  end # (nested) class Configuration

  ## lets you use
  ##   Webget.configure do |config|
  ##      config.sleep = 10
  ##   end
  def self.configure() yield( config ); end
  def self.config()    @config ||= Configuration.new;  end



  ## note - assumes json format 
  ##   encoding always utf-8 by definition! - double check?)
  def self.call( url, headers: {} )  
    response = _get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      ## note: use format json for pretty printing and parse check!!!!
      Webcache.record( url, response,
                       format: 'json' )
    else
      ## todo/check - log error
      puts "!! HTTP ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.call

  ## todo/check: rename encoding to html/http-like charset - why? why not?
  ##   check encoding UTF-8 or utf-8  - makes a difference?
  def self.page( url, encoding: 'UTF-8', headers: {} )  ## assumes html format
    response = _get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      Webcache.record( url, response,
                       encoding: encoding  )   ## assumes format: html (default)
    else
      ## todo/check - log error
      puts "!! HTTP ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.page


  ## assumes txt format
  def self.text( url, path: nil, headers: {} )  
    response = _get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      ## note: like json assumes always utf-8 encoding for now !!!
      Webcache.record( url, response,
                       path: path,   ## optional "custom" (file)path for saving in cache
                       format: 'txt' )
    else
      ## todo/check - log error
      puts "!! HTTP ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.text



  ## todo/check: rename to csv or file or records or - why? why not?
  ## todo/check: rename encoding to html/http-like charset - why? why not?
  def self.dataset( url, encoding: 'UTF-8', headers: {} )  ## assumes csv format
    response = _get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      Webcache.record( url, response,
                       encoding: encoding,
                       format:   'csv' )    ## pass along csv format - why? why not?
    else
      ## todo/check - log error
      puts "!! HTTP ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.dataset



  ####
  ##  private helpers 
  ##   make private - why? why not?
  def self._get( url, headers: {} )
     @@requests ||= 0     ## track number of requests

     if @@requests > 0    ## note - do NOT sleep on very first request!!!
       puts "  sleep #{config.sleep} sec(s)..."
       sleep( config.sleep )   ## slow down - sleep x secs before each http request
     end

     @@requests += 1
     Webclient.get( url, headers: headers )  ## returns respone
  end
end  # class Webget

