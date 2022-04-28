
$LOAD_PATH.unshift( "./lib" )
require 'webclient'



url = 'https://live---metadata-5covpqijaa-uc.a.run.app/metadata/0'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts "content_type: #{res.content_type}"
puts "content_length: #{res.content_length} bytes (#{res.content_length.class.name})"
pp res.content_length

#=>  application/json
#=>  407 bytes (Integer)

url = 'https://live---metadata-5covpqijaa-uc.a.run.app/images/0'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts "content_type: #{res.content_type}"
puts "content_length: #{res.content_length} bytes (#{res.content_length.class.name})"
pp res.content_length

#=>  image/png
#=>    bytes (NilClass)



url = 'https://raw.githubusercontent.com/openfootball/football.json/master/2015-16/en.1.clubs.json'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts "content_type: #{res.content_type}"
puts "content_length: #{res.content_length} bytes"

puts
puts "text (string encoding: utf-8):"
puts res.text
puts
puts "json:"
puts res.json
puts
puts "blob (binary string encoding: ASCII-8BIT/BINARY):"
puts res.body
puts


url = 'https://www.football-data.co.uk/mmz4281/1920/E0.csv'
res = Webclient.get( url )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts "content_type: #{res.content_type}"
puts "content_length: #{res.content_length} bytes"

puts
puts "text:"
text = res.text( encoding: 'Windows-1252' )
puts text
puts text.encoding



