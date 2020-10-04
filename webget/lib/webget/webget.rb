
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



  def self.call( url, headers: {} )  ## assumes json format
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


  def self.page( url, headers: {} )  ## assumes html format
    puts "  sleep #{config.sleep} sec(s)..."
    sleep( config.sleep )   ## slow down - sleep 3secs before each http request

    response = Webclient.get( url, headers: headers )

    if response.status.ok?  ## must be HTTP 200
      puts "#{response.status.code} #{response.status.message}"
      Webcache.record( url, response )   ## assumes format: html (default)
    else
      ## todo/check - log error
      puts "!! ERROR - #{response.status.code} #{response.status.message}:"
      pp response.raw  ## note: dump inner (raw) response (NOT the wrapped)
    end

    ## to be done / continued
    response
  end  # method self.page

end  # class Webget

