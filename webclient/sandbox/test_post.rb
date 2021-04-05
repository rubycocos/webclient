
$LOAD_PATH.unshift( "./lib" )
require 'webclient'



url = 'https://api.thegraph.com/subgraphs/name/itsjerryokolo/cryptopunks'

query = <<GRAPHQL
{
   transactions(  first:   10,
                  orderBy: date,
                  where: { date_gte: "1498017600",
                           punk_not: "" } )
      {
          id
          date
          block    # done
      }
}
GRAPHQL

res = Webclient.post( url, json: {
                             query: query } )
puts res.status.code       #=> 200
puts res.status.message    #=> OK
puts res.status.ok?

puts
puts "text:"
puts res.text
puts
puts "json:"
puts res.json

