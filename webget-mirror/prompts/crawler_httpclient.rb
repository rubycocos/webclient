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
