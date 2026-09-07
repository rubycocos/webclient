
## TODOs


- [x] add to webget
            check for bom
            check for html charset (on html content type)
            add x-encoding-source
            add x-utf8-replace


- [x]  add new  x-encoding-source  ->  bom|html|http|user | possibly fallback/default?
- [x]   check for charset in html page  in webclient text !!!
- [ ]   check for charset in http content type - why? why not??
- [x]  add new  x-utf8-replace    - track replace counts in utf-8 encode !!!


- [x]  update db schema
         add encoding_source
         add encoding_valid
         add  chars_8bit     ## nil or  count tabs/tabstops in html source (use tab or tabs ??)
         add  utf8_replace  ??
