###
#  to run use
#     ruby -I ./lib -I ./test test/test_get.rb

require 'helper'

class TestGet < MiniTest::Test

  def test_get
    url = 'https://raw.githubusercontent.com/rubycoco/fetcher/master/fetcher/README.md'
    worker = Fetcher::Worker.new
    res = worker.get( url )
    pp res

    assert_equal '200',        res.code             # note: returned code is a string e.g. '200' not 200
    assert_equal 'OK',         res.message
    assert_equal 'text/plain', res.content_type

    assert_equal File.read( './README.md' ), res.body   # local README.md should match remote README.md
  end

  def test_get_with_socket_error
    url = 'http://pragdave.blogs.pragprog.com/pragdave/atom.xml'
    worker = Fetcher::Worker.new

    # note: will raise SocketError -- getaddrinfo: Name or service not known
    assert_raises( SocketError ) do
      res = worker.get( url )
      pp res
    end
  end

  def test_get_not_found
    url = 'http://blog.engineyard.com/category/ruby/feed'
    worker = Fetcher::Worker.new
    res = worker.get( url )
    pp res

    # note: feed link/url no longer exists, thus, 404 -- not found
    assert_equal '404', res.code
  end

  def test_get_cookie_redirect
    url = 'https://link.springer.com/search.rss?search-within=Journal&facet-journal-id=10827'
    worker = Fetcher::Worker.new
    res = worker.get( url )
    pp res

    assert_equal '200',        res.code             # note: returned code is a string e.g. '200' not 200
    assert_equal 'OK',         res.message
    assert_equal 'text/xml', res.content_type

  end

end # class TestGet
