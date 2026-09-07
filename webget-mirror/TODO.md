
## TODOs


- [ ] add to webget
            check for bom
            check for html charset (on html content type)
            add x-encoding-source
            add x-encoding-replace
            add x-tabs ??


- [ ]  add new  x-encoding-source  ->  bom|html|http|user | possibly fallback/default?
- [ ]   check for charset in html page  in webclient text !!!
- [ ]   check for charset in http content type - why? why not??
- [ ]  add new  x-encoding-replace    - track replace counts in utf-8 encode !!!


- [ ]  update db schema
         add encoding_source
         add encoding_valid  ??
         add  chars_8bit     ## nil or  count tabs/tabstops in html source (use tab or tabs ??)
         add  utf8_replace  ??
