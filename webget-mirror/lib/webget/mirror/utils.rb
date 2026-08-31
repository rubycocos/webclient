
HTML_CHARSET_RE = %r{
   <meta [ ]+
       [^<>]*?        ## note - use non-greedy (shortest) match
  \bcharset
        [ ]*=[ ]*
          ['"]?       ## optional opening quote
        (?<charset>[a-z0-9-]+)
}ix


HTML_DOCTYPE_RE = %r{
   <!DOCTYPE [ ]+
        (?<doctype> [^<>]+?)  ## note - use non-greedy (shortest) match
                               ## do NOT allow opening/closing brackets for now
                               ##  ever possible? double check
            [ ]*
   >
}ix




def fmt_time_diff( time_start, time_end=Time.now, count:, step: nil )
   time_diff  = time_end - time_start
   buf = String.new

     if count == 0 || step == 0
       buf +=  "  %d:%02d mins" % [time_diff/60, time_diff%60]
     elsif step
       buf +=  "  [#{step}/#{count} - %5.2f%%]" % [step*100/count]

       buf +=  "  %d:%02d mins" % [time_diff/60, time_diff%60]
       buf +=  " - %5.2f secs/page" % [time_diff/step]

       time_estimate = (time_diff/step) * count
       buf +=  ", estimate: %d:%02d mins" % [time_estimate/60, time_estimate%60]
    else
      buf +=  "  %d:%02d mins" % [time_diff/60, time_diff%60]
      buf +=  " - %5.2f secs/page  (#{count} pages)" % [time_diff/count]
   end

   buf
end
