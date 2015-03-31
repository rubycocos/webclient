# encoding: utf-8

###
# NB: for local testing run like:
#
# 1.9.x: ruby -Ilib lib/fetcher.rb

# core and stlibs

require 'yaml'              ### used ??? remove??
require 'logger'            ### used ??? remove??

require 'fileutils'         ### used ??? remove??
require 'uri'
require 'net/http'
require 'net/https'
require 'ostruct'
require 'date'
require 'cgi'
require 'pp'


# 3rd party gems

require 'logutils'

# our own code

require 'fetcher/version'   # let version always go first
require 'fetcher/worker'


module Fetcher

  def self.main

    ## NB: only load (require) cli code if called

    require 'fetcher/cli/runner'
    
    # allow env variable to set RUBYOPT-style default command line options
    #   e.g. -o site 
    fetcheropt = ENV[ 'FETCHEROPT' ]
    
    args = []
    args += fetcheropt.split if fetcheropt
    args += ARGV.dup
    
    Runner.new.run(args)
  end


  #############################
  # convenience shortcuts

  def self.copy( src, dest, opts={} )
    Worker.new.copy( src, dest, opts )
  end


  def self.read( src )
    Worker.new.read( src )
  end

  def self.read_blob!( src )
    Worker.new.read_blob!( src )
  end

  def self.read_utf8!( src )
    Worker.new.read_utf8!( src )
  end


  def self.get( src )
    Worker.new.get( src )
  end

end  # module Fetcher


if __FILE__ == $0
  Fetcher.main
else
  # say hello
  puts Fetcher.banner    if $DEBUG || (defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG)
end
