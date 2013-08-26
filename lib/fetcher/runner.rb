
module Fetcher

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

    include LogUtils::Logging
    
    attr_reader :opts
    
    def initialize
      @opts         = Opts.new
    end
    
    def run( args )
      opt=OptionParser.new do |cmd|
    
        cmd.banner = "Usage: fetch [options] uri"
    
        cmd.on( '-o', '--output PATH', 'Output Path' ) { |s| opts.put( 'output', s ) }

        # todo: find different letter for debug trace switch (use v for version?)
        cmd.on( "-v", "--verbose", "Show debug trace" )  do
           # todo/fix: use/change to logutils settings for level
           # logger.datetime_format = "%H:%H:%S"
           # logger.level = Logger::DEBUG
        end

      usage =<<EOS
 
fetch #{VERSION} - Lets you fetch text documents or binary blobs via HTTP, HTTPS.

#{cmd.help}

Examples:
  fetch https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt
  fetch -o downloads https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt

Further information:
  https://github.com/geraldb/fetcher

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
        
        Worker.new.copy( src, dest )

      end # each arg

      puts 'Done.'
      
    end   # method run
    
  end # class Runner

end  # module Fetcher
