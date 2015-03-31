# encoding: utf-8

require 'helper'

class TestGet < MiniTest::Test

  def test_get
    url = 'https://raw.github.com/rubylibs/fetcher/master/README.md'
    worker = Fetcher::Worker.new
    res = worker.get( url )
    pp res

    assert_equal '200', res.code             # note: returned code is a string e.g. '200' not 200
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

end # class TestGet
