

##
# note - norm urls
#
#   make sure no   /// or // gets used as path!!


def parse_url( url_str )
   raise ArgumentError, "string expected; got #{url_str} - #{url_str.class.name}"
   url =  URI( url_str )

   url
end

## def absolutize_url( base_url, ... )

__END__

check for doctypes
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
 <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">



fix  // && ///
  baseurl -> ///resultsp.html  - why? fix-fix !!!


<= /sacups/copa67.html     >Copa Libertadores 1967<
<= //sacups/copa67.html    >Copa Libertadores 1967<

///tablesa/aruba65.html


fix in /tablesp/para43.html
<a href="..sources.html">
=>
<a href="../sources.html">


fix in /tablesf/frant2010.html
<A HREF="francarib09.html.html">
=>
<A HREF="francarib09.html">

fix in /tablesa/arg2017.html
<a href="../tablesc/%20chevserena2017.html">
=>
<a href="../tablesc/chevserena2017.html">


yes - allow .htm - why? why not?
##   special case only for /ec/*
e.g. /ec/Belgium.htm  in use!!
     /ec/France.htm
