

module MirrorDb
    def self.open( path='./mirror.db' )

      ### reuse connect here !!!
      ###   why? why not?

      config = {
          adapter:  'sqlite3',
          database: path,
      }

      ActiveRecord::Base.establish_connection( config )
      # ActiveRecord::Base.logger = Logger.new( STDOUT )

        ## try to speed up sqlite
        ##   see http://www.sqlite.org/pragma.html
        con = ActiveRecord::Base.connection
        con.execute( 'PRAGMA synchronous=OFF;' )
        con.execute( 'PRAGMA journal_mode=OFF;' )
        con.execute( 'PRAGMA temp_store=MEMORY;' )

      ##########################
      ### auto_migrate
      unless Model::Page.table_exists?
          CreateDb.new.up
      end
    end  # method open
end



__END__


=begin
    def self.open_readonly( path='./mirror.db' )

       ### raise ArgumentError, "sqlite db #{path} not found"  if !File.exist?( path )


      config = {
          adapter:  'sqlite3',
          database: path,
          readonly: true,   ## try readonly prop!!!
      }

      ActiveRecord::Base.establish_connection( config )
      # ActiveRecord::Base.logger = Logger.new( STDOUT )

        ## try to speed up sqlite
        ##   see http://www.sqlite.org/pragma.html
        con = ActiveRecord::Base.connection

        ## add for read-only - why? why not?
       # con.execute( 'PRAGMA query_only=ON;' )

       # con.execute( 'PRAGMA synchronous=OFF;' )
       # con.execute( 'PRAGMA journal_mode=OFF;' )
       # con.execute( 'PRAGMA temp_store=MEMORY;' )
    end
=end
