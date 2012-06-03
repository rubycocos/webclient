
module Fetcher

   def self.copy( src, dest )
      Worker.new( Logger.new(STDOUT) ).copy( src, dest )
   end


  class Opts
  
    def initialize
      @hash = {}
    end
    
    def put( key, value )
      @hash[ key.to_s ] = value
    end    
  
    def output_path
      @hash.fetch( 'output', '.' )
    end

  end # class Opts


  class Runner
    
    attr_reader :logger
    attr_reader :opts
    
    def initialize
      @logger       = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @opts         = Opts.new
    end
    
    def run( args )
      opt=OptionParser.new do |cmd|
    
        cmd.banner = "Usage: fetch [options] uri"
    
        cmd.on( '-o', '--output PATH', 'Output Path' ) { |s| opts.put( 'output', s ) }

        # todo: find different letter for debug trace switch (use v for version?)
        cmd.on( "-v", "--verbose", "Show debug trace" )  do
           logger.datetime_format = "%H:%H:%S"
           logger.level = Logger::DEBUG
        end

      usage =<<EOS
 
fetch - Lets you fetch text documents or binary blobs via HTTP, HTTPS.

#{cmd.help}

Examples:
  fetch http://geraldb.github.com/rubybook/hoe.html
  fetch -o downloads http://geraldb.github.com/rubybook/hoe.html

Further information:
  http://geraldb.github.com/fetcher

EOS
 
        cmd.on_tail( "-h", "--help", "Show this message" ) do
           puts usage
           exit
        end
      end

      opt.parse!( args )
  
      puts Fetcher.banner
          
      args.each do |arg|
        
        src = arg
        uri = URI.parse( src )
        
        logger.debug "uri.host=<#{uri.host}>, uri.path=<#{uri.path}>"
        
        if uri.path == '/' || uri.path == ''
          dest = "#{uri.host}"
        else
          dest = "#{uri.host}@#{uri.path.gsub( /[ \-]/, '_').gsub( /[\/\\]/, '-')}"
        end
        
        ## todo: use output path option
        
        Worker.new( logger ).copy( src, dest )

      end # each arg

      puts "Done."
      
    end   # method run
    
  end # class Runner

end  # module Fetcher

