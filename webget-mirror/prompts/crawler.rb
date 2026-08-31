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

class DiskCache
  def initialize(directory, ttl)
    @directory = directory
    @ttl = ttl

    FileUtils.mkdir_p(@directory)
  end

  def key(url)
    Digest::SHA256.hexdigest(url)
  end

  def paths(url)
    digest = key(url)

    {
      body:     File.join(@directory, "#{digest}.body"),
      metadata: File.join(@directory, "#{digest}.json")
    }
  end

  def exists?(url)
    paths = paths(url)
    File.exist?(paths[:body]) && File.exist?(paths[:metadata])
  end

  def get(url)
    return nil unless exists?(url)

    paths = paths(url)

    begin
      metadata = JSON.parse(File.read(paths[:metadata]))

      fetched_at = Time.parse(metadata.fetch("fetched_at"))

      if @ttl && (Time.now - fetched_at > @ttl)
        return nil
      end

      body = File.binread(paths[:body])

      {
        url:         metadata["url"],
        status:      metadata["status"],
        headers:     metadata["headers"] || {},
        content_type: metadata["content_type"],
        fetched_at:  fetched_at,
        body:        body
      }
    rescue StandardError => e
      warn "[CACHE] Failed reading #{url}: #{e.message}"
      nil
    end
  end

  def put(url, response)
    paths = paths(url)

    metadata = {
      "url"          => url,
      "status"       => response.code.to_i,
      "headers"      => response.each_header.to_h,
      "content_type" => response["content-type"],
      "fetched_at"   => Time.now.utc.iso8601
    }

    # Write temporary files first, then rename them.
    # This prevents partially-written cache entries.
    body_tmp = "#{paths[:body]}.tmp"
    meta_tmp = "#{paths[:metadata]}.tmp"

    File.binwrite(body_tmp, response.body)
    File.write(meta_tmp, JSON.pretty_generate(metadata))

    File.rename(body_tmp, paths[:body])
    File.rename(meta_tmp, paths[:metadata])

    true
  rescue StandardError => e
    warn "[CACHE] Failed writing #{url}: #{e.message}"
    false
  ensure
    File.delete(body_tmp) if body_tmp && File.exist?(body_tmp)
    File.delete(meta_tmp) if meta_tmp && File.exist?(meta_tmp)
  end
end

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

class RobotsTxt
  Rule = Struct.new(:user_agent, :groups)

  def initialize(http_client, user_agent)
    @http = http_client
    @user_agent = user_agent

    @cache = {}
    @mutex = Mutex.new
  end

  def allowed?(url)
    uri = URI.parse(url)

    robots_url = "#{uri.scheme}://#{uri.host}"

    robots_url += ":#{uri.port}" unless [80, 443].include?(uri.port)

    robots_url += "/robots.txt"

    rules = get_rules(robots_url)

    rules.empty? || allowed_by_rules?(uri.path.empty? ? "/" : uri.path, rules)
  rescue URI::InvalidURIError
    false
  end

  private

  def get_rules(robots_url)
    @mutex.synchronize do
      return @cache[robots_url] if @cache.key?(robots_url)
    end

    response = @http.get(robots_url, use_cache: true)

    rules =
      if response && response[:status].between?(200, 299)
        parse(response[:body])
      elsif response && response[:status] == 404
        []
      else
        # Fail closed when robots.txt cannot be retrieved.
        [["*", []]]
      end

    @mutex.synchronize do
      @cache[robots_url] = rules
    end

    rules
  end

  def parse(body)
    groups = []
    current_agents = []
    current_rules = []

    body.to_s.each_line do |line|
      line = line.sub(/#.*/, "").strip
      next if line.empty?

      key, value = line.split(":", 2)
      next unless key && value

      key = key.strip.downcase
      value = value.strip

      case key
      when "user-agent"
        unless current_agents.empty?
          groups << [current_agents, current_rules]
          current_agents = []
          current_rules = []
        end

        current_agents << value.downcase

      when "disallow"
        current_rules << ["disallow", value] unless current_agents.empty?

      when "allow"
        current_rules << ["allow", value] unless current_agents.empty?
      end
    end

    unless current_agents.empty?
      groups << [current_agents, current_rules]
    end

    groups
  end

  def allowed_by_rules?(path, groups)
    # Prefer an exact user-agent group; otherwise use "*".
    selected =
      groups.select { |agents, _| agents.include?(@user_agent.downcase) }

    selected = groups.select { |agents, _| agents.include?("*") } if selected.empty?

    return true if selected.empty?

    rules = selected.flat_map(&:last)

    matching = rules.select do |type, pattern|
      next false if pattern.empty?

      if pattern.end_with?("$")
        path.start_with?(pattern[0...-1]) && path == pattern[0...-1]
      else
        path.start_with?(pattern)
      end
    end

    return true if matching.empty?

    # Longest matching rule wins.
    matching.max_by { |_, pattern| pattern.gsub(/\$$/, "").length }[0] == "allow"
  end
end

# ============================================================
# HTTP Client
# ============================================================

class HttpClient
  Response = Struct.new(
    :status,
    :headers,
    :body,
    :url,
    keyword_init: true
  )

  REDIRECT_CODES = [301, 302, 303, 307, 308].freeze

  def initialize(config, cache, rate_limiter)
    @config = config
    @cache = cache
    @rate_limiter = rate_limiter
  end

  def get(url, use_cache: true)
    if use_cache
      cached = @cache.get(url)

      if cached
        puts "[CACHE] #{url}"

        return {
          status: cached[:status].to_i,
          headers: cached[:headers],
          body: cached[:body],
          url: cached[:url],
          cached: true
        }
      end
    end

    fetch(url)
  end

  private

  def fetch(url, redirect_limit = 5)
    attempts = 0

    begin
      attempts += 1

      @rate_limiter.wait

      uri = URI.parse(url)

      raise "Unsupported scheme: #{uri.scheme}" unless
        %w[http https].include?(uri.scheme)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      http.open_timeout = @config.open_timeout
      http.read_timeout = @config.timeout

      request = Net::HTTP::Get.new(uri.request_uri)

      request["User-Agent"] = @config.user_agent
      request["Accept"] = "text/html,application/xhtml+xml"

      puts "[HTTP] GET #{url}"

      response = http.request(request)

      # Handle redirects.
      if REDIRECT_CODES.include?(response.code.to_i) &&
         response["location"] &&
         redirect_limit > 0

        redirected_url = URI.join(url, response["location"]).to_s

        puts "[REDIRECT] #{url} -> #{redirected_url}"

        return fetch(redirected_url, redirect_limit - 1)
      end

      result = {
        status: response.code.to_i,
        headers: response.each_header.to_h,
        body: response.body,
        url: url,
        cached: false
      }

      # Cache successful responses and normal HTTP responses.
      if response.code.to_i >= 200 && response.code.to_i < 400
        @cache.put(url, response)
      end

      result

    rescue StandardError => e
      if attempts < @config.retries
        delay = 2 ** (attempts - 1)

        warn "[RETRY] #{url}: #{e.class}: #{e.message}"
        warn "[RETRY] Waiting #{delay}s..."

        sleep(delay)

        retry
      end

      warn "[ERROR] #{url}: #{e.class}: #{e.message}"

      nil
    end
  end
end

# ============================================================
# URL Normalizer
# ============================================================

class UrlNormalizer
  TRACKING_PARAMETERS = %w[
    utm_source
    utm_medium
    utm_campaign
    utm_term
    utm_content
    gclid
    fbclid
  ].freeze

  def normalize(base_url, href)
    return nil if href.nil?

    href = href.strip

    return nil if href.empty?
    return nil if href.start_with?("#")
    return nil if href =~ /\A(?:javascript|mailto|tel|data):/i

    begin
      uri = URI.join(base_url, href)

      return nil unless %w[http https].include?(uri.scheme)

      uri.fragment = nil

      if uri.query
        params = URI.decode_www_form(uri.query)

        params.reject! do |key, _|
          TRACKING_PARAMETERS.include?(key.downcase)
        end

        params.sort_by! { |key, value| [key, value] }

        uri.query =
          if params.empty?
            nil
          else
            URI.encode_www_form(params)
          end
      end

      # Remove default ports.
      if (uri.scheme == "http" && uri.port == 80) ||
         (uri.scheme == "https" && uri.port == 443)
        uri.port = nil
      end

      # Normalize trailing slash only for root.
      uri.path = "/" if uri.path.nil? || uri.path.empty?

      uri.to_s
    rescue URI::InvalidURIError
      nil
    end
  end
end

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