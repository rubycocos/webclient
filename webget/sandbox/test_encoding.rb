$LOAD_PATH.unshift( "../webclient/lib" )
$LOAD_PATH.unshift( "./lib" )
require 'webget'


puts Webcache.home   ## built-in helper for checking home directory

puts Webcache.root
puts Webcache.config.root

Webcache.root = './cache'

puts Webcache.root
puts Webcache.config.root

=begin
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<head/><META http-equiv=Content-Type content="text/html; charset=windows-1250">
<HTML>
<HEAD>
<TITLE>Bosnia-Hercegovina 2025/26</TITLE>
</HEAD>
<H2>Bosnia-Hercegovina 2025/26</H2>
<p>
=end

urls = [
  'https://rsssf.org/tablesa/aus2025.html',
  'https://rsssf.org/tablesb/bih2026.html',  ## incl. html meta charset=windows-1250 !!
  'https://rsssf.org/tablesd/duit2026.html',
]


urls.each do |url|
  res = Webget.page( url, encoding: 'Windows-1252' )
  puts res.status.code       #=> 200
  puts res.status.message    #=> OK
  puts res.status.ok?

  puts
  puts "text:"
  puts res.text[0..200]
end


puts "bye"
