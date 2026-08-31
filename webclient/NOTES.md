# Net::HTTP Notes and More

https://en.wikipedia.org/wiki/List_of_HTTP_header_fields


how to handle duplicate headers?
see -> https://ruby-doc.org/3.0.4/stdlibs/net/Net/HTTPHeader.html
       https://cdocs.ruby-lang.org/en/master/Net/HTTPHeader.html


```
request.add_field 'X-My-Header', 'a'
p request['X-My-Header']              #=> "a"
p request.get_fields('X-My-Header')   #=> ["a"]
request.add_field 'X-My-Header', 'b'
p request['X-My-Header']              #=> "a, b"
p request.get_fields('X-My-Header')   #=> ["a", "b"]
request.add_field 'X-My-Header', 'c'
p request['X-My-Header']              #=> "a, b, c"
p request.get_fields('X-My-Header')   #=> ["a", "b", "c"]
```



To read HTTP headers from a Net::HTTP response, you can treat the response object like a hash or access its methods to retrieve header fields.
Here are the primary ways to interact with headers,
including how to handle multiple values for duplicate fields (like Set-Cookie):

## 1. Reading Standard Headers (Case-Insensitive)

You can fetch any header value using the bracket notation []
or the get_fields method. Net::HTTP handles header names case-insensitively, so response['content-type'] and response['Content-Type'] yield the same result.

```
require 'net/http'
require 'uri'

response = Net::HTTP.get_response(URI('https://httpbin.org'))

# Get a single header value (if multiple exist, joins them with commas)
content_type = response['content-type']
puts "Content-Type: #{content_type}"
```


## 2. Handling Duplicate Header Fields (Multiple Entries)
When an HTTP response contains multiple headers with the exact same name (most commonly Set-Cookie), standard bracket notation response['set-cookie'] will join them into a single comma-separated string.
To get them as a clean, individual array of strings, use get_fields:

```
# Imagine the server sent three separate "Set-Cookie" header lines

# Option A: Bracket notation (Joins them into one string)
cookies_string = response['set-cookie']
# Output: "cookie1=abc; path=/, cookie2=xyz; path=/"

# Option B: get_fields (Keeps them as an Array) - BEST FOR DUPLICATES
cookies_array = response.get_fields('set-cookie')
# Output: ["cookie1=abc; path=/", "cookie2=xyz; path=/"]

cookies_array&.each do |cookie|
  puts "Found Cookie: #{cookie}"end
```

## 3. Iterating Through All Headers
If you want to inspect or print every header returned by the server, use each_header:

```
response.each_header do |key, value|
  puts "#{key}: #{value}"
end
```





---

about redirects

add redirects later - why? why not? see fetch gem

```
require 'net/http'

uri = URI 'http://localhost:4567/oldpage'

res = Net::HTTP.get_response uri
if res.code == "302"
    res = Net::HTTP.get_response URI res.header['location']
end

puts res.body
```