
class Webget   # a web (go get) crawler

  class Configuration  ## nested class

    #######################
    ## accessors
    def sleep()       @sleep || 3; end     ### todo/check: use delay / wait or such?
    def sleep=(value) @sleep = value; end

  end # (nested) class Configuration

  ## lets you use
  ##   Webget.configure do |config|
  ##      config.sleep = 10
  ##   end
  def self.configure() yield( config ); end
  def self.config()    @config ||= Configuration.new;  end



  def self.call( url, headers: {} )  ## assumes json format (note - encoding always utf-8 by definition! - double check?)
    puts "  sleep #{config.sleep} sec(s)..."
    sleep( config.sleep )   ## slow down - sleep 3secs before each http request

    response = Webclient.get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      ## note: use format json for pretty printing and parse check!!!!
      Webcache.record( url, response,
                       format: 'json' )
    else
      ## todo/check - log error
      puts "!! ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.call

  ## todo/check: rename encoding to html/http-like charset - why? why not?
  def self.page( url, encoding: 'UTF-8', headers: {} )  ## assumes html format
    puts "  sleep #{config.sleep} sec(s)..."
    sleep( config.sleep )   ## slow down - sleep 3secs before each http request

    response = Webclient.get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      Webcache.record( url, response,
                       encoding: encoding  )   ## assumes format: html (default)
    else
      ## todo/check - log error
      puts "!! ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.page


  ## todo/check: rename to csv or file or records or - why? why not?
  ## todo/check: rename encoding to html/http-like charset - why? why not?
  def self.dataset( url, encoding: 'UTF-8', headers: {} )  ## assumes csv format
    puts "  sleep #{config.sleep} sec(s)..."
    sleep( config.sleep )   ## slow down - sleep 3secs before each http request

    response = Webclient.get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      Webcache.record( url, response,
                       encoding: encoding,
                       format:   'csv' )    ## pass along csv format - why? why not?
    else
      ## todo/check - log error
      puts "!! ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.dataset


end  # class Webget

