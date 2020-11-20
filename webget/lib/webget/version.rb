
class Webget

  MAJOR = 0    ## todo: namespace inside version or something - why? why not??
  MINOR = 2
  PATCH = 3
  VERSION = [MAJOR,MINOR,PATCH].join('.')

  def self.version
    VERSION
  end

  # version string for generator meta tag (includes ruby version)
  def self.banner
    "webget/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
  end

  def self.root
    "#{File.expand_path( File.dirname(File.dirname(File.dirname(__FILE__))) )}"
  end

end  # module Webget

