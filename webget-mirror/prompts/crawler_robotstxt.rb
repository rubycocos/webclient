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
