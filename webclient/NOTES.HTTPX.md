# Notes on HTTPX

the response object

keep it simple?

```
response = HTTPX.get("https://httpbin.org")

puts response.status         # => 200
puts response.version        # => "2.0"
puts response.uri.to_s       # => "https://httpbin.org"
puts response.headers["content-type"] # => "application/json
```

- [ ] use response.status    instead of  response.status.code ?
- [ ] use response.version   instead of  response.status.http_version ?


what about response.status.message|msg?

the HTTPX::Response object does not provide a built-in method or text property (like .status_message or .reason)
to return text phrases like "Not Found" or "OK".
This is primarily because the modern HTTP/2 protocol completely omitted status text phrases
from its spec to save bandwidth—only the numeric code is transmitted.
