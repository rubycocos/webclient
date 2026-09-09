

###
# fix-fix-fix
#    make regex more "generic"
#
# add real-world samples here

=begin

rsssf.org/tableso/oost2014.html:
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-2">
rsssf.org/tablesn/nz-intres.html:
   <meta http-equiv="content-type" content="text/html; charset=UTF-16LE">
rsssf.org/tablesa/argchamp.html:
   <meta http-equiv="Content-Type" content="text/html; charset=UTFs-8">
   => typo  - UTFs-8 !!!
rsssf.org/tables/2002full.html:
   <META http-equiv="Content-Type" content="text/html; charset=UTF-8">
rsssf.org/miscellaneous/zwed-coach-triv.html:
   <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
rsssf.org/tablesr/roem68.html:
   <META http-equiv=Content-Type content="text/html; charset=windows-1250">

=end



HTML_CHARSET_RE = %r{
   <meta [ ]+
       [^<>]*?        ## note - use non-greedy (shortest) match
  \bcharset
        [ ]*=[ ]*
          ['"]?       ## optional opening quote
        (?<charset>[a-z0-9_-]+)
}ix


HTML_DOCTYPE_RE = %r{
   <!DOCTYPE [ ]+
        (?<doctype> [^<>]+?)  ## note - use non-greedy (shortest) match
                               ## do NOT allow opening/closing brackets for now
                               ##  ever possible? double check
            [ ]*
   >
}ix



def _collect_page_info( doc, html: )

           ## use collect_page_stat( doc: )
           ##   or   collect_page_info  ( pass in nokogiri doc !!)
           ##     PageInfo   (or Page::Info), PageStat
           ##       - title
           ##       - html_doctype
           ##       - html_charset
           ##       - tabs
           ##       ...

           ### try to find page title
           ##    not - title might be missing (nil)!!
             title_el =  doc.at_css('title')
             title =  title_el ? title_el.text.strip :  nil

    ##
             ##  note - use "plain-old" regex
             ##     to get "raw" doctype/charset  from html source
             ##
             ## record doctype
             ##  e.g
             ##  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
             ##  <!DOCTYPE HTML>
             ## and html charset (inside meta)
             ##  e.g.
             ## <meta http-equiv="Content-Type" content="text/html; charset=Windows-1252">
             ## <meta charset="Windows-1252">

             ###
             ## note -   limit search to 1024 ( or allow double 2048)

             html_doctype =  (m=HTML_DOCTYPE_RE.match( html[0,1024] )) ? m[:doctype] : nil
             html_charset =  (m=HTML_CHARSET_RE.match( html[0,1024] )) ? m[:charset] : nil


             ## check for tabs  - make it nil if no tabs found otherwise use count
             tabs = html.scan( "\t" )
             tabs =  tabs.size == 0 ? nil : tabs.size


   meta = {
     title:        title,
     html_doctype: html_doctype,
     html_charset: html_charset,
     tabs:         tabs,
   }

   meta
end