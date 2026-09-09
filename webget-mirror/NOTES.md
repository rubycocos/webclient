
# Notes


```


TITLE_RE = %r{
    <TITLE>(?<text>.*?)</TITLE>
}ixm



https://rsssf.org/miscellaneous/ec-qual.html

minimal page with no title   uses <head/> !!!
e.g
<html>
<head/><pre>
Contributed by ...
</pre>
</html>


if encoding == 'windows-1252'
            ## try a quick check if proper encoding
            ## search for title in page
           if  m=TITLE_RE.match( html )
              puts "  page title: #{m[:text].strip}"
           else
             puts "error - no title found in html - encoding error?"
             exit 1
           end
        end

or


<head/><pre>
Austria, OeFB ("Magnofit") Cup 1996/97
  ...
<p>
Last updated: 28 May 1997

</pre>
  in https://rsssf.org/tableso/oostcup97.html

```