# (more) Notes on charset encodings

- [ ]  add  normalize/compose after conversion to utf-8 in text

# Imagine one page gives you a decomposed string, and another gives you a composed one
player_nfd = "Zine\u0065\u0301dine Zidane" # Decomposed (e + accent)
player_nfc = "Zin\u00E9dine Zidane"       # Composed (é)

puts player_nfd == player_nfc
# => false (This will break database searches!)

# Normalize both strings to Composed (NFC)
normalized_nfd = player_nfd.unicode_normalize(:nfc)
normalized_nfc = player_nfc.unicode_normalize(:nfc)

puts normalized_nfd == normalized_nfc
# => true (Fixed!)

Why CP1252 (Windows-1252) is swapped for ISO-8859-1
The script safely
swaps ISO-8859-1 out for CP1252 (Windows-1252).
Legally, the standard ISO-8859-1 encoding leaves bytes 128–159 empty
for control characters.
Microsoft's CP1252 fills those blank slots with highly common formatting marks
like the smart quotes (“”), the trademark symbol (™), and the en-dash (–).

Web browsers inherently treat ISO-8859-1 text as Windows-1252 to avoid breaking these common symbols, and this script mimics that behavior.

q: double-check and ask/prompt what is the difference between
Windows-1252 and ISO-8859-1  charset encodings?



```
##
## unicode
##    also call normalize on unicode??
## towo ways to write 'é':
##  Composed:   'é' = U+00E9 (1 code point)
##   Decomposed: 'é' = U+0065 + U+0301 (2 code points)
##
##    Normalize to NFC (composed form)
##   return unicodedata.normalize("NFC", text)

##
Code Point Range	Bytes	Bit Pattern	Data Bits
U+0000 to U+007F	1	0xxxxxxx	7
U+0080 to U+07FF	2	110xxxxx 10xxxxxx	11
U+0800 to U+FFFF, excluding U+D800 to U+DFFF	3	1110xxxx 10xxxxxx 10xxxxxx	16
U+10000 to U+10FFFF	4	11110xxx 10xxxxxx 10xxxxxx 10xxxxxx	21

f the first bit is 0, it's a 1-byte character (ASCII)
If the first bits are 110, it's a 2-byte character
If the first bits are 1110, it's a 3-byte character
If the first bits are 11110, it's a 4-byte character
Continuation bytes always start with 10

A Byte Order Mark is a special Unicode character (U+FEFF) placed at the beginning of a text file to indicate the byte order (endianness) of the encoding. In UTF-8, it serves only as an encoding signature since UTF-8 has no endianness issues.

UTF-8 technically doesn't need a BOM since it has no byte-order ambiguity. However, Microsoft tools often add a UTF-8 BOM (EF BB BF) to indicate the file is UTF-8 rather than some other encoding.

UTF-8: Has a specific pattern of continuation bytes (always 10xxxxxx for non-first bytes)
UTF-16: Often has many null bytes (0x00) for ASCII text stored as two-byte code units
ISO-8859-1: Bytes 0x80-0x9F are control characters (rarely seen in normal prose)
Windows-1252: Assigns many bytes in 0x80-0x9F to printable characters such as curly quotes and the euro sign (a few byte values remain undefined)


For data produced before 2000, Latin-1 or Windows-1252 is a reasonable second guess for Western European text.

ISO-8859-1 (Latin-1): Western European languages (French, German, Spanish, Portuguese)

ISO-8859-5: Cyrillic alphabets (Russian, Bulgarian, Serbian)

Windows-1252: A closely related Microsoft encoding that assigns printable characters such as curly quotes to much of the 128-159 range, where Latin-1 has control codes


UTF-8 Mojibake Patterns (decoded as Windows-1252):
---------------------------------------------
Original   Mojibake        UTF-8 bytes
---------------------------------------------
'é'        'Ã©'           2
'ñ'        'Ã±'           2
'ü'        'Ã¼'           2
'中'        'ä¸­'           3
'—'        'â€”'           3
'“'        'â€œ'           3
'’'        'â€™'           3


```



## The Golden Strategy

To safely convert these pages to UTF-8 without breaking characters:

1) Use Ruby's Net::HTTP to download the raw body as binary string data (ASCII-8BIT).
   This prevents Ruby from forcing an incorrect default encoding guess.
2) Read the server headers or a <meta> tag to find an encoding clue.
3) Fall back to ISO-8859-1 / Windows-1252 if no encoding is explicitly announced
   (which is common for older pages).
4) Use String#encode with invalid: :replace and undef: :replace to gracefully
   catch and drop corrupted fallback bytes.