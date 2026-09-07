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
      def to_int() @code; end

      ##  note - allow compare with integer e.g.
      ##          response.status == 200
      def ==(other)
        other.is_a?(Status) ? code == other.code : code == other.to_i
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
