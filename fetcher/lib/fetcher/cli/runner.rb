# encoding: utf-8


# more core and stlibs

require 'optparse'

# our own code (for command line interface/cli)

require 'fetcher/cli/opts'


module Fetcher

  class Runner

    include LogUtils::Logging

    attr_reader :opts
        
    def initialize
      @opts = Opts.new
    end
    
    def run( args )
      opt=OptionParser.new do |cmd|

        cmd.banner = "Usage: fetch [options] URI"

        cmd.on( '-o', '--output PATH', "Output Path (default is '#{opts.output_path}')" ) { |s| opts.output_path = s }

        # todo: find different letter for debug trace switch (use v for version?)
        cmd.on( '-v', '--verbose', 'Show debug trace' )  do
           LogUtils::Logger.root.level = :debug
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

        ## todo: also add -?  if possible as alternative
        cmd.on_tail( '-h', '--help', 'Show this message' ) do
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
          dest = "#{opts.output_path}/#{uri.host}"
        else
          dest = "#{opts.output_path}/#{uri.host}@#{uri.path.gsub( /[ \-]/, '_').gsub( /[\/\\]/, '-')}"
        end

        Worker.new.copy( src, dest )

      end # each arg

      puts 'Done.'
      
    end   # method run
    
  end # class Runner

end  # module Fetcher
