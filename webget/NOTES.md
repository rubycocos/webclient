# Notes


- [ ] maybe check for html
       inside text for meta charset???
      or check content-type  -- why? why not?

```
# 1. Get raw binary data so Ruby doesn't guess the encoding yet
  raw_body = response.body.b

  # 2. Determine source encoding (Check Content-Type header first)
  content_type = response['content-type'] || ''
  source_encoding = 'ISO-8859-1' # Default fallback for legacy sites like RSSSF

  if content_type.include?('charset=')
    source_encoding = content_type.split('charset=').last.strip
  elsif raw_body =~ /<meta.*charset=["']?([^"' >]+)/i
    # Fallback: scan the raw HTML text for a meta charset tag
    source_encoding = $1
  end

  # 3. Handle specific vendor encodings gracefully
  source_encoding = 'CP1252' if source_encoding.upcase == 'ISO-8859-1'

```





- [x] add custom headers


```
## add HTTP/1.1 200 OK   too - why? why not?

x-url:        #   x-addr ++ x-fil
x-addr:       # The original URL address part.
x-fil:        # The original URL path part.
x-encoding:   # original charset encoding, text always stored in utf-8!!

x-save:       # The local filename, depending on user's "build structure" x-size:       # The stored (either in cache, or in an external file) data size
preferences.
```

The One Exception: URL Fragments (#)The only part of a URL path structure that is not recorded in X-URL is the URL fragment (anything after a # symbol, such as https://example.com).


- [ ] maybe later check if possible to convert to
       standard ISO WARC web logs?
        see


- [ ]  maybe track 404 NOT FOUND - why? why not?

```
Example 3: Error Page Tracking (404 Not Found)HTTrack captures error instances to avoid repeatedly querying missing structural files on subsequent syncs.httpX-URL: https://example.com
X-Status: 404
X-Mime: text/html
X-Size: 1204
```



## Cache Format

try to learn from <https://www.httrack.com/html/cache.html> !!!




## More Cache Gems (to checkout)

- <https://github.com/gurgeous/httpdisk>

- <https://github.com/DannyBen/webcache> - hassle-free caching for HTTP download
- <https://github.com/DannyBen/lightly> -  a file cache for performing heavy tasks, lightly


- <https://github.com/dannguyen/active_scraper>
- <https://github.com/vcr/vcr>


## More Web Crawler Gems (to checkout)

- <https://github.com/gurgeous/sinew> - a ruby DSL for structured web crawling, with a robust caching system


## Web Crawler / Spider / Scraper Names

- Gopher ?   => Webgo e.g. Webgo.get   - Why? Why not?

well known crawlers (and user agent strings):
- Googlebot  by Google
- Bingbot   by Microsoft
- Slurp  by Yahoo!
-
- ??
- more <http://www.robotstxt.org/db.html>



## Web Crawler Config / Settings

```
User-agent: *
Crawl-Delay: 20
```


## Resources

- <https://en.wikipedia.org/wiki/Web_scraping>
- <https://en.wikipedia.org/wiki/Web_crawler>
- <https://en.wikipedia.org/wiki/Googlebot>
