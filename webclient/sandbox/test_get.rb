
$LOAD_PATH.unshift( "./lib" )
require 'webclient'



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




url = 'http://www.football-data.co.uk/mmz4281/1920/E0.csv'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts
puts "text:"
text = res.text( encoding: 'Windows-1252' )
puts text
puts text.encoding



