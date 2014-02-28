# encoding: utf-8

require 'helper'

class TestGet < MiniTest::Unit::TestCase

  def test_get

    worker = Fetcher::Worker.new
    res = worker.get( 'https://raw.github.com/rubylibs/fetcher/master/README.md' )

    pp res

    assert_equal '200', res.code             # => '200' 
                               #  Note: Returned (status) code is a string e.g. '404'
    assert_equal 'OK', res.message          # => 'OK'
    # puts response.body
    # puts response.content_type     # =

  end

end # class TestCopy
