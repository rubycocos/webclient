
## encoding tips

```
Leverage Native Auto-Detection (Ruby 3+)
Modern versions of Ruby include built-in macro logic for detecting charset headers and <meta> tags. By setting res.body_encoding = true on the response object, Ruby will automatically inspect the Content-Type header and scan the internal HTML body tags to re-encode the response string into a matched Ruby encoding object

# Enable native charset extraction from Content-Type and <meta> tags

response.body_encoding = true
puts "Detected Encoding: #{response.body.encoding}"


own pipeline

(i) Read the Content-Type Header
content_type = response['content-type'] # e.g., "text/html; charset=utf-8"
charset = content_type&.match(/charset=([\w-]+)/i)&.captures&.first

if charset
  # Convert the extracted string name into a real Ruby Encoding object
  ruby_encoding = Encoding.find(charset)
  html_body = response.body.force_encoding(ruby_encoding).encode("UTF-8")
end

(ii)
B. Fallback to HTML <meta> Tag Analysis
If the server forgot
to supply a charset header, it will usually declare it inside the HTML <meta> tags.
You can search the raw unencoded body using a regex pattern:

# Scan for HTML5 <meta charset="..."> or HTML4 equivalents
meta_match = response.body.match(/<meta.*?charset=["']?([\w-]+)/i)
charset = meta_match ? meta_match[1] : "UTF-8" # Default to UTF-8 if missing entirely

html_body = response.body.force_encoding(charset).encode("UTF-8")

(iii)
Step 3: Use Nokogiri (The Gold Standard)
If you are scraping web pages or interacting heavily with DOM nodes, skip manual header calculations and pair Net::HTTP with the nokogiri gem.
Much like Python's BeautifulSoup, Nokogiri features a built-in heavy lifting system
that reads raw binary payload strings (ASCII-8BIT), extracts the implicit XML/HTML
structural layout tags, tracks the correct character set,
and translates everything safely to UTF-8.

require 'net/http'
require 'uri'
require 'nokogiri'

uri = URI("https://example.com")
response = Net::HTTP.get_response(uri)

# Pass the completely raw binary bytes directly to Nokogiri
doc = Nokogiri::HTML(response.body)

# Nokogiri automatically handles encoding conversion safely internally
puts "Page Title: #{doc.title}"


(iiii)
Step 4: Handle Scrambled String Failures (Heuristics)
If you hit an esoteric web page using broken headers or misaligned encodings that break your scripts, you can leverage the charlock_holmes gem. It acts as an underlying equivalent to Python's charset-normalizer, analyzing textual byte density distributions to suggest appropriate conversions.

# gem install charlock_holmes
require 'charlock_holmes'

# Analyze raw server string bytes
detection = CharlockHolmes::EncodingDetector.detect(response.body)

if detection[:encoding]
  # Force map and transition string cleanly
  html_body = CharlockHolmes::Converter.convert(response.body, detection[:encoding], 'UTF-8')
end


see https://github.com/brianmario/charlock_holmes

more
in python see
  https://bytetunnels.com/posts/charset-detection-python-chardet-cchardet-charset-normalizer/




The ISO-8859-1 check matters because RFC 2616 specifies that HTTP responses with text/* content types default to ISO-8859-1
when no charset is declared.
Many servers omit the charset, and requests falls back to this default even when the actual content is UTF-8.

ASCII-compatible encodings: If the content is pure ASCII (bytes 0x00-0x7F), all three libraries correctly report ASCII, but this tells you nothing about what the intended encoding was.
```