# encoding: utf-8

require 'helper'

###
# to run use
#  ruby -I ./lib -I ./test test/test_read.rb

class TestRead < MiniTest::Test

  def test_read_not_found
    url = 'http://blog.engineyard.com/category/ruby/feed'
    worker = Fetcher::Worker.new

    assert_raises( Fetcher::HttpError ) do
      res = worker.read( url )
      pp res
    end
  end

end # class TestRead

