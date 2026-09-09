
class Webget
class Mirror
   MAJOR = 0    ## todo: namespace inside version or something - why? why not??
   MINOR = 0
   PATCH = 1
   VERSION = [MAJOR,MINOR,PATCH].join('.')

  def self.version
    VERSION
  end

  # version string for generator meta tag (includes ruby version)
  def self.banner
    "webget-mirror/#{VERSION} on Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}] in (#{root})"
  end

  def self.root
    File.expand_path( File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))) )
  end
end  # class Mirror
end  # class Webget
