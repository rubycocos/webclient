###
# NB: for local testing run like:
#
# 1.8.x: ruby -Ilib -rrubygems lib/fetcher.rb
# 1.9.x: ruby -Ilib lib/fetcher.rb

# core and stlibs

require 'yaml'
require 'pp'
require 'logger'
require 'optparse'
require 'fileutils'


# our own code

require 'fetcher/runner'


module Fetcher

  VERSION = '0.0.1'

  # version string for generator meta tag (includes ruby version)
  def self.banner
    "Fetcher #{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.main
    
    # allow env variable to set RUBYOPT-style default command line options
    #   e.g. -o site 
    fetcheropt = ENV[ 'FETCHEROPT' ]
    
    args = []
    args += fetcheropt.split if fetcheropt
    args += ARGV.dup
    
    Runner.new.run(args)
  end

end  # module Fetcher


Fetcher.main if __FILE__ == $0