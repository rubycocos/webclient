# fetcher - Fetch Text Documents or Binary Blobs via HTTP, HTTPS

* home  :: [github.com/rubylibs/fetcher](https://github.com/rubylibs/fetcher)
* bugs  :: [github.com/rubylibs/fetcher/issues](https://github.com/rubylibs/fetcher/issues)
* gem   :: [rubygems.org/gems/fetcher](https://rubygems.org/gems/fetcher)
* rdoc  :: [rubydoc.info/gems/fetcher](http://rubydoc.info/gems/fetcher)
* forum :: [groups.google.com/group/webslideshow](https://groups.google.com/group/webslideshow)


## Usage

### Copy (to File)

    Fetcher.copy( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt', '/tmp/bl.txt' )

or

    worker = Fetcher::Worker.new
    worker.copy( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt', '/tmp/bl.txt' )


### Read (into String)

    txt = Fetcher.read( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt' )

or

    worker = Fetcher::Worker.new
    txt = worker.read( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt' )

Note: The method `read` will return a string.


### Get (HTTP Response)

    response = Fetcher.get( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt' )

or

    worker = Fetcher::Worker.new
    response = worker.get( 'https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt' )

Note: The method `get` will return a `Net::HTTPResponse` object
(lets you use code, headers, body, etc.).

    puts response.code             # => '404' 
                                   #  Note: Returned (status) code is a string e.g. '404'
    puts response.message          # => 'Not Found'
    puts response.body
    puts response.content_type     # => 'text/html; charset=UTF-8'
    puts response['content-type']  # => 'text/html; charset=UTF-8'
                                   #  Note: Headers are always downcased
                                   #        e.g. use 'content-type' not 'Content-Type'


## Command Line

~~~
fetch version 0.5.0 - Lets you fetch text documents or binary blobs via HTTP, HTTPS.

Usage: fetch [options] URI
    -o, --output PATH                Output Path (default is '.')
    -v, --verbose                    Show debug trace


Examples:
  fetch https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt
  fetch -o downloads https://raw.github.com/openfootball/at-austria/master/2013_14/bl.txt
~~~


## Install

Just install the gem:

    $ gem install fetcher


## Real World Usage

The [`slideshow`](http://slideshow-s9.github.io) (also known as Slide Show (S9)) gem
that lets you create slide shows
and author slides in plain text using a wiki-style markup language that's easy-to-write and easy-to-read
ships with the `fetcher` gem.

The [`pluto`](https://github.com/feedreader) gem that lets you build web pages
from published web feeds
ships with the `fetcher` gem.

The [`sportdb`](https://github.com/geraldb/sport.db.ruby) gem that lets you read football (soccer) fixtures
and more in plain text
ships with the `fetcher` gem.


## License

The `fetcher` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.