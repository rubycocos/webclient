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
