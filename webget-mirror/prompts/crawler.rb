##
###  via chatgpt prompt (aug 2026)



#!/usr/bin/env ruby

require "net/http"
require "uri"
require "nokogiri"
require "json"
require "digest"
require "fileutils"
require "set"
require "time"
require "thread"

# ============================================================
# Configuration
# ============================================================

class Config
  attr_accessor :start_url,
                :cache_dir,
                :cache_ttl,
                :max_depth,
                :max_pages,
                :delay,
                :timeout,
                :open_timeout,
                :retries,
                :user_agent,
                :same_host_only

  def initialize(start_url)
    @start_url       = start_url
    @cache_dir       = "cache"
    @cache_ttl       = 24 * 60 * 60       # 24 hours
    @max_depth       = 3
    @max_pages       = 100
    @delay           = 1.0                # seconds between requests
    @timeout         = 20
    @open_timeout    = 10
    @retries         = 3
    @user_agent      = "RubyDiskCrawler/1.0"
    @same_host_only  = true
  end
end

# ============================================================
# Disk Cache
# ============================================================

# see crawler_diskcache.rb

# ============================================================
# Rate Limiter
# ============================================================

class RateLimiter
  def initialize(delay)
    @delay = delay
    @mutex = Mutex.new
    @last_request = nil
  end

  def wait
    @mutex.synchronize do
      if @last_request
        elapsed = Time.now - @last_request
        remaining = @delay - elapsed

        sleep(remaining) if remaining > 0
      end

      @last_request = Time.now
    end
  end
end


# ============================================================
# robots.txt
# ============================================================

# see crawler_robotstxt.rb


# ============================================================
# HTTP Client
# ============================================================

# see crawler_httpclient.rb


# ============================================================
# URL Normalizer
# ============================================================

#  see crawler_urlnomralizer.rb

# ============================================================
# Crawler
# ============================================================

class Crawler
  def initialize(config)
    @config = config

    @cache = DiskCache.new(
      config.cache_dir,
      config.cache_ttl
    )

    @rate_limiter = RateLimiter.new(config.delay)

    @http = HttpClient.new(
      config,
      @cache,
      @rate_limiter
    )

    @robots = RobotsTxt.new(
      @http,
      config.user_agent
    )

    @normalizer = UrlNormalizer.new

    @visited = Set.new
    @queued = Set.new

    @queue = Queue.new

    @pages_crawled = 0
    @stop = false
  end

  def run
    start_url = @normalizer.normalize(
      @config.start_url,
      @config.start_url
    )

    unless start_url
      abort "Invalid start URL: #{@config.start_url}"
    end

    trap("INT") do
      puts "\n[STOP] Interrupt received. Finishing..."
      @stop = true
    end

    @queue << [start_url, 0]
    @queued << start_url

    until @queue.empty? || @stop
      break if @pages_crawled >= @config.max_pages

      url, depth = @queue.pop

      next if @visited.include?(url)

      if depth > @config.max_depth
        next
      end

      unless @robots.allowed?(url)
        puts "[ROBOTS] Blocked #{url}"
        @visited << url
        next
      end

      @visited << url

      response = @http.get(url)

      unless response
        next
      end

      status = response[:status].to_i

      puts "[STATUS] #{status} #{url}"

      unless status.between?(200, 299)
        next
      end

      content_type = response[:headers]["content-type"].to_s.downcase

      unless html_content?(content_type)
        puts "[SKIP] Not HTML: #{url}"
        next
      end

      @pages_crawled += 1

      html = response[:body].to_s

      document = parse_html(html)

      links = extract_links(document, url)

      puts "[PAGE] depth=#{depth} links=#{links.length} #{url}"

      links.each do |link|
        break if @stop
        break if @pages_crawled >= @config.max_pages

        next if @visited.include?(link)
        next if @queued.include?(link)

        if @config.same_host_only
          next unless same_host?(start_url, link)
        end

        next_depth = depth + 1

        next if next_depth > @config.max_depth

        unless @robots.allowed?(link)
          puts "[ROBOTS] Blocked #{link}"
          next
        end

        @queued << link
        @queue << [link, next_depth]
      end
    end

    print_summary
  end

  private

  def html_content?(content_type)
    content_type.include?("text/html") ||
      content_type.include?("application/xhtml+xml")
  end

  def parse_html(html)
    Nokogiri::HTML.parse(
      html,
      nil,
      "UTF-8"
    )
  end

  def extract_links(document, base_url)
    links = Set.new

    document.css("a[href]").each do |anchor|
      href = anchor["href"]

      url = @normalizer.normalize(
        base_url,
        href
      )

      links << url if url
    end

    links.to_a
  end

  def same_host?(url_a, url_b)
    a = URI.parse(url_a)
    b = URI.parse(url_b)

    a.host.downcase == b.host.downcase &&
      effective_port(a) == effective_port(b)
  rescue URI::InvalidURIError
    false
  end

  def effective_port(uri)
    return uri.port if uri.port

    uri.scheme == "https" ? 443 : 80
  end

  def print_summary
    puts
    puts "=========================================="
    puts "Crawl finished"
    puts "=========================================="
    puts "Pages crawled : #{@pages_crawled}"
    puts "URLs visited  : #{@visited.length}"
    puts "URLs queued   : #{@queued.length}"
    puts "Cache         : #{@config.cache_dir}"
    puts "=========================================="
  end
end

# ============================================================
# Command Line
# ============================================================

if ARGV.empty?
  puts <<~USAGE
    Usage:
      ruby crawler.rb URL [options]

    Example:
      ruby crawler.rb https://example.com

    Options:
      --depth N       Maximum crawl depth (default: 3)
      --pages N       Maximum pages (default: 100)
      --delay N       Delay between requests in seconds (default: 1)
      --ttl N         Cache TTL in seconds (default: 86400)
      --cache DIR     Cache directory (default: cache)
      --retries N     Number of retries (default: 3)
      --timeout N     HTTP read timeout (default: 20)
      --all-hosts     Follow links to other hosts
      --user-agent X  Custom User-Agent

    Examples:

      ruby crawler.rb https://example.com --depth 2 --pages 50

      ruby crawler.rb https://example.com --ttl 3600 --delay 2

      ruby crawler.rb https://example.com --all-hosts
  USAGE

  exit 1
end

start_url = ARGV.shift

config = Config.new(start_url)

i = 0

while i < ARGV.length
  case ARGV[i]
  when "--depth"
    i += 1
    config.max_depth = Integer(ARGV[i])

  when "--pages"
    i += 1
    config.max_pages = Integer(ARGV[i])

  when "--delay"
    i += 1
    config.delay = Float(ARGV[i])

  when "--ttl"
    i += 1
    config.cache_ttl = Integer(ARGV[i])

  when "--cache"
    i += 1
    config.cache_dir = ARGV[i]

  when "--retries"
    i += 1
    config.retries = Integer(ARGV[i])

  when "--timeout"
    i += 1
    config.timeout = Integer(ARGV[i])

  when "--all-hosts"
    config.same_host_only = false

  when "--user-agent"
    i += 1
    config.user_agent = ARGV[i]

  else
    warn "Unknown option: #{ARGV[i]}"
    exit 1
  end

  i += 1
end

crawler = Crawler.new(config)
crawler.run