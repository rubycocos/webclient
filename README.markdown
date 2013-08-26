# fetcher - Fetch Text Documents or Binary Blobs via HTTP, HTTPS

* home  :: [github.com/geraldb/fetcher](https://github.com/geraldb/fetcher)
* bugs  :: [github.com/geraldb/fetcher/issues](https://github.com/geraldb/fetcher/issues)
* gem   :: [rubygems.org/gems/fetcher](https://rubygems.org/gems/fetcher)
* rdoc  :: [rubydoc.info/gems/fetcher](http://rubydoc.info/gems/fetcher)
* forum :: [groups.google.com/group/webslideshow](https://groups.google.com/group/webslideshow)


## Description


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



## Install

Just install the gem:

    $ gem install fetcher


## Real World Usage

The [`slideshow`](http://slideshow-s9.github.io) (also known as Slide Show (S9)) gem
that lets you create slide shows
and author slides in plain text using a wiki-style markup language that's easy-to-write and easy-to-read
ships with the `fetcher` gem.

The [`sportdb`](https://github.com/geraldb/sport.db.ruby) gem that lets you read football (soccer) fixtures
and more in plain text
ships with the `fetcher` gem.



## License

The `fetcher` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.