$LOAD_PATH.unshift( "../webclient/lib" )
$LOAD_PATH.unshift( "./lib" )
require 'webget'


puts Webcache.home   ## built-in helper for checking home directory

puts Webcache.root
puts Webcache.config.root

Webcache.root = './cache'

puts Webcache.root
puts Webcache.config.root



url = 'https://raw.githubusercontent.com/openfootball/football.json/master/2015-16/en.1.clubs.json'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts
puts "text:"
puts res.text
puts
puts "json:"
puts res.json


Webcache.record( url, res )

puts Webcache.exist?( url )
puts Webcache.cached?( url )

puts Webcache.exist?( 'http://foo.com/bar' )
puts Webcache.cached?( 'http://foo.com/bar' )

meta = Webcache.read_meta( url )
pp meta
pp meta.to_h
pp meta.date
pp meta['date']
pp Time.now
pp Time.now.utc

pp meta.expired?
pp meta.expired?( Time.now.utc+60*60 )   ## 1h in future (always expired)

pp Webcache.expired?( 'http://foo.com/bar' )
pp Webcache.expired?( 'http://foo.com/bar', expires_in: Time.now.utc+60*60 )
pp Webcache.expired_in_12h?( 'http://foo.com/bar' )
pp Webcache.expired_in_24h?( 'http://foo.com/bar' )
pp Webcache.expired_in_1d?( 'http://foo.com/bar' )

pp Webcache.expired?( url )
pp Webcache.expired?( url, expires_in: Time.now.utc+60*60 )



url = 'http://www.football-data.co.uk/mmz4281/1920/E0.csv'
res = Webget.dataset( url, encoding: 'Windows-1252' )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts
puts "text:"
puts res.text( encoding: 'Windows-1252' )


url = 'https://fbref.com/en/comps/56/schedule/Austrian-Bundesliga-Scores-and-Fixtures'
res = Webget.page( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts
puts "text:"
puts res.text[0..200]


puts "bye"

