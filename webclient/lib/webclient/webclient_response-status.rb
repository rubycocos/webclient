class Webclient
  class Response

    #####################
    # nested class  Response::Status
    class Status
      ### fix-fix-fix
      ##  maybe fold back
      ##      into response.status | status_code
      ##           response.status_message | status_msg
      ##         keep it simple?
      ##
      ##   keep status.ok?    =>  response.ok?
      ##   keep status.nok?   =>  response.nok?

      attr_reader :code

      def initialize( code, message: nil )
        ## note - upstream Net::HTTP::Response::code is a string e.g. "200"!!!
        ##             convert to integer number
        @code    = code.to_i(10)
        @message = message
      end


      def to_i()   @code; end    ## use alias_method :to_id, :code - why? why not?
      def to_int() @code; end   ## treat Status as Integer  (but NOT as String with to_str)

      ## use "404 NOT FOUND"
      ##     "200 OK"          or such
      def to_s()   "#{code} #{message}";  end
      ## add to_str too  - keep to_int for now ony - why? why not?
      ##  note - to_str unlocks
      ##   By defining to_str, your custom object can seamlessly participate
      ##  in native string mechanics without you needing to manually type .to_s everywhere:
      ##   - String Concatenation: "status is " + status works without raising a TypeError.
      ##   - Array Joining: [status1, status2].join(",") will smoothly coerce the objects.
      ##   - File paths: Using your custom object inside File.open(your_object)
      ##                 or Dir.entries(your_object)
      ##   - and more


      ##  note - allow compare with integer e.g.
      ##          response.status == 200
      ##          response.status == "200"    ## uses String#to_i
      ##                etc.
      def ==(other)
        other.is_a?(Status) ? code == other.code
                            : other.respond_to?(:to_i) ? code == other.to_i : false
      end


      def ok?()  code == 200; end
      def nok?() code != 200; end

      def success?()   (200..299).include?(code); end
      def redirect?()  (300..399).include?(code); end
      def error?()     code >= 400; end


      def message() @message; end
      alias_method :msg, :message   ## add/keep shorter alias too - why? why not?
    end  # (nested) class Status


end  # class Response
end  # class Webclient
