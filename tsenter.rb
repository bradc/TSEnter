=begin
  


Initial version (.01)
- E.g. 
  - s1411 e1416 "install_pag:mTH-re:done=ok
  - v<enter>
- Simple input
  - Start time
  - End time
  - Description
- Add commands
  - s#### -start time
  - e#### -end time
  - "     -Description
  - v -verify all entries (i.e. for incorrect task#'s, etc.)

Version .02
- Add more complex data input
  - Function code
  - Project
  - Task
  - Project=Task construct
  - Minutes
- Add commands
  - f -specifies a function code
  - p -specifies a project code
  - t -specifies a task number
  - m -specifies minutes (uses start time+minutes; or previous end time+minutes)

Version .03
- Add commands
  - i# =insert a new entry before the specified number
  - d# =delete specified entry
  - #  =modify specified entry
  - l  =list last entry
  - l# =list specified entry
  - la =list all entries
  - l#-#=list entries between # and # (inclusive)

Version .04
- Add commands
  - uid=i -marks a user as 'in'
  - o -marks user as being 'out'
  - g -marks user as being 'gone' for the day
  - l<task#> -list all ts entries with a task#
  
  - vt -verify time

Version .05
- Add commands
  - x -executes a spawned command
  - t -show current time and date

Version .06
- Add command
  - gr(oup) field1=field2[=fieldn] -groups ts entries by user specified criteria
                               e.g. group task#,
=end

=begin
  Example:
    :start_time => Command.new('start time', 'retrieve start time from imput', :validate=>{|t| t>0}){|_| _.sub!(/s\d{2,4}/i, '')}
=end

#tsenter
require 'command_line'
require 'shell'
require 'db_adapter'

module TS

  class Configure
    attr_accessor :conf
    def initialize
      @conf=Hash.new
      if block_given? 
        yield(self)
      end
    end
  end

  class Entry    
    # raises TS::InvalidEntry exception if verification fails.
    def initialize entry
    end

  end

  class Enter    
    def initialize config
      # will need to initialize db if the proper tables don't exist yet.
      # possibly done a gone and need a new table for today's entries.
      @store= config[:db]
    end

    # Code duplication
    # Possible solution is to put entry validation and save into a proc
    # which gets called at the appropriate time.
    def start arg=nil
      unless arg.nil?
        # if arguments are non-nil, then likely user has invoked
        # Enter with a single entry and expects program to terminate
        # after verifying and storing the entry.
        begin
          entry = TS::Entry.new(arg)
          # @store is an object of a class that implements a DataStore interface.
          # i.e. an adapter for KirbyBase or MySQL.
          @store.save(entry)
        rescue TS::InvalidEntry => e
          #TODO: might be useful to have a 'context here' to be able to point
          # to the portion of the entry that is causing the problem.
          puts "Entry is invalid: #{e.what}"
        resuce DataStore::Exception => dse
          puts "DataStore Error: #{dse.what}"
        end
      else
        # Arguments are nil, likely user wants to enter interactive mode
        # so start the Enter shell, and accept input.
        @shell=Shell.new :promt=>'*'
        @shell.run do |input|
          begin
            entry=TS::Entry.new(input)
            @store.save(entry)
          rescue TS::InvalidEntry => e
            puts "Entry is not valid: #{e.what}"
          end
        end
      end
    end
  end

end

if __FILE__ == $0
  # CommandLine will process program switches, if/when needed
  # for now it simply strips off any switches and concatenates 
  # the remaining.  Assuming the remaining is a ts entry.
  args = CommandLine.new(ARGV)
  # Assume some default entries, such as default local data store
  # we'll assume for now that KirbyBase will be used as the local
  # store.
  config = TS::Configure.new do |conf|
    # Only adapter for now, later will be updated to handle other
    # commandline configurations. 
    # E.g. of setting a text editor for long descriptions.
    #  conf.editor='notepad.exe'
    conf.db= DataStore.new(:adapter=>:KirbyBase, :local=>true)
  end
  TS::Enter.new(config).start(args)
end