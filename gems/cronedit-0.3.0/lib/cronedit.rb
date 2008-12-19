# :title:CronEdit - Ruby editior library for cron and crontab - RDoc documentation
# =CronEdit - Ruby editor library for crontab.
# 
# Allows to manipulate crontab from comfortably from ruby code. 
# You can add/modify/remove (aka CRUD) named crontab entries individually with no effect on the rest of your crontab.
# You can define cron entry definitions as standard text definitions <tt>'10 * * * * echo 42'</tt> or using Hash notation <tt>{:minute=>10, :command=>'echo 42'}</tt> (see CronEntry ::DEFAULTS)
# Additionally you can parse cron text definitions to Hash. 
#
# From other features: CronEdit allows you to make bulk updates of crontab; the same way you manipulate live crontab you can edit file or in-memory definitions and combine them arbitrarily. 
# 
# ==Install
# * Available as gem: <tt>gem install cronedit</tt>
# * Project development page, downloads, forum, svn: http://rubyforge.org/projects/cronedit/
#
# ==Usage
# 
# Class methods offer quick crontab operations. Three examples:
#       CronEdit::Crontab.Add  'agent1', '5,35 0-23/2 * * * echo agent1'
#       CronEdit::Crontab.Add  'agent2', {:minute=>5, :command=>'echo 42'}
#       CronEdit::Crontab.Remove 'someId'
# 
# Define a batch update and list the current content: 
# 
#       cm = CronEdit::Crontab.new 'user'
#       cm.add 'agent1', '5,35 0-23/2 * * * echo agent1'
#       ...
#       cm.add 'agent2', {:minute=>5, :command=>'echo 42'}
#       cm.commit
#       p cm.list
#
# see CronEdit::Crontab class for all available methods
#
# You can do a bulk merge (or removal) of definitions from a file using CronEdit::FileCrontab
#       fc = FileCrontab.new 'example1.cron'
#       Crontab.Merge fc
#       p Crontab.List
#       Crontab.Subtract fc
#
# Similary to CronEdit::FileCrontab you can you also CronEdit::DummyCrontab for in-memory crontabs.
# Above all, you can combine all three crontab implementations Crontab, FileCrontab, DummyCrontab arbitrarily.
#
# see <tt>test/examples/examples.rb</tt> for more examples !
#       
# ==Author
# Viktor Zigo, http://alephzarro.com, All rights reserved. You can redistribute it and/or modify it under the same terms as Ruby.
# (parts of the  cronentry definition parsing code originally by gotoken@notwork.org)
#
# Sponsored by: http://7inf.com
# ==History
# * version: 0.3.0  2008-02-02
# ** keeps/survives full fromatting; FileCrontab; DummyCrontab; bulk addition and removal; clear crontab; more testcases; examples; and other
# * version: 0.2.0 
#
# ==TODO
# * add Utils: getNext execution
# * platform specific options (headers; vixiecron vs. dilloncron) 
module CronEdit
    self::VERSION = '0.3.0' unless defined? self::VERSION
    
    # Main class that manipulates actual system cron. Additionally, it is the base class for other types of Crontab utils (FileCrontab, DummyCrontab)
    class Crontab
        # Use crontab for user aUser
        def initialize aUser = nil
            @user = aUser
            @opts = {:close_input=>true, :close_output=>true}
            rollback()
        end

        class <<self
            # Add a new crontab entry definition. (see instance method add).
            def Add anId, aDef
                cm = self.new
                entry = cm.add anId, aDef
                cm.commit
                entry
            end
        
            #  Remove a crontab entry definitions identified by anIds from current crontab (see instance method remove).
            def Remove *anIds
                cm = self.new
                cm.remove *anIds
                cm.commit
            end
        
            # List current crontab.
            def List
                self.new.list
            end        
        
            #Merges this crontab with another one (see instance method merge).
            def Merge anotherCrontab
                cm=self.new
                cm.merge anotherCrontab
                cm.commit
            end         
        
            #Removes crontab definitions of another crontab (see instance method subtract).
            def Subtract anotherCrontab
                cm=self.new
                cm.subtract anotherCrontab
                cm.commit
            end         
        
        end
    
        # Add a new crontab entry definition. Becomes effective only after commit().
        # * aDef is can be a standart text definition or a Hash definition (see CronEntry::DEFAULTS)
        # * anId is an identification of the entry (for later modification or deletion)
        # returns newly added CronEntry
        def add anId, aDef
            @adds[anId.to_s] = CronEntry.new( aDef )
            @removals.delete anId.to_s
        end

        # Bulk addition/merging of  crontab definitions from another Crontab (FileCrontab, DummyCrontab, or a Crontab of another user)
        def merge aCrontab
            entries, lines = aCrontab.listFull
            #todo: we throw the incoming lines away
            #merge original data
            @adds.merge! entries
            #merge noncommited data as well
            aCrontab.adds.each {|k,v| @adds[k]=v}
            aCrontab.removals.each {|k,v| remove k}
            self
        end 
    
        # Bulk subtraction/removal of crontab definitions from another Crontab (FileCrontab, DummyCrontab, or a Crontab of another user)
        def subtract aCrontab
            entries, lines = aCrontab.listFull
            entries.each {|id,entry| remove id}
            aCrontab.adds.each {|id,entry| remove id}
        end
    
        # Remove a crontab entry definitions identified by anIds. Becomes effective only after commit().
        def remove *anIds
            anIds.each { |id|
                @adds.delete id.to_s
                @removals[id.to_s]=id.to_s
            }
        end
        
        # Merges the existing crontab with all modifications and installs the new crontab.
        # returns the merged parsed crontab hash
        def commit
            # merge crontab
            currentEntries, lines = listFull()
            mergedEntries = nil
            # install it
            io = getOutput
            begin
                mergedEntries = dumpCron currentEntries, lines, io
            ensure
                io.close if @opts[:close_output]
            end
            # No idea why but without this any wait crontab reads and writes appears not synchronizes
            sleep 0.01
            #clean changes :)
            rollback()
            mergedEntries
        end
        
        # Discards all modifications (since last commit, or creation)
        def rollback
            @adds = {}
            @removals = {}
        end
    
        # Clear crontab completely and immediately. Warning: no commit needed (no rollback anymore)
        def clear!
            rollback
            # we dont do it using crontab command  (-r , -d) because it differs on various platfoms (vixiecron vs. dilloncron)
            io = getOutput
            begin
                io << ''
            ensure
                io.close if @opts[:close_output]
            end
        end
    
        # A helper method that prints out the items to be added and removed
        def review
            puts "To be added: #{@adds.inspect}"
            puts "To be removed: #{@removals.keys.inspect}"
        end
        
        # Read the current crontab and parse it
        # returns a Hash (entry id or index)=>CronEntry
        def list
            res = listFull
            res ? res[0] : nil
        end

        # Read the current crontab and parse it, keeping the format
        # returns a [entires, lines]  where entries = Hash (entry id or index)=>CronEntry; lines = Array of Strings of EntryPlaceholders
        def listFull
            io = getInput
            begin
                return parseCrontabFull(io)
            ensure
                io.close if @opts[:close_input]
            end
        end
    
        # Lists raw content from crontab
        # returns array of text lines
        def listRaw
            io = getInput
            begin
                entries = io.readlines
                return (entries.first =~ /^no/).nil? ? entries : []   #returns empty list if no entry
            ensure
                io.close if @opts[:close_input]
            end
        end    
    
        #Set alternative I/O for reading/writing cron entries. If set, the respective stream will be used instead of calling system 'crontab'
        def setIO anInput, anOutput
            @input = anInput
            @output = anOutput
            self
        end
    protected
        # Parses cron definition from a stream
        # returns Hash of id->CrontEntries
        def parseCrontab anIO
            res = parseCrontabFull(anIO)
            res ? res[0] : nil
        end
    
        # Parses cron definition from a stream
        # returns [hash of CronEntries, Array of all lines (and placeholders)]
        def parseCrontabFull anIO
                lines=[]
                entries = {}
                idx = 0
                id = nil
                anIO.each_line { |l|
                    l.strip!
                    lines << l if l.empty? #  keep empty lines           and opts[:keepformat]
                    next if l.empty?
                    return [entries, lines] unless (l =~ /^no crontab/).nil? # if crontab contains no schedule it returns 'no crontab for ...'
        
                    if l=~/^#/    #is it comment or ID ?
                        id = EntryPlaceholder.Create l
                        lines << l unless id #add the raw line to the lines if no id
                    elsif not (l =~ /^\w+\ *=/).nil?  # is it variable definition ?
                        lines << l
                        id = nil
                    else # it should be cron entry definition
                        id = EntryPlaceholder.new(idx+=1) unless id # if there is no id generate an anonymous id
                        lines << id #add placeholder to lines
                        key = id.id  
                        entries[key.to_s]=l
                        id = nil
                    end
                }
                [entries, lines]
        end    

    private
        def dumpCron anEntries, aLines, anIO
            currentEntries=anEntries.clone
            currentEntries.delete_if {|id, entry| @removals.include? id}
            mergedEntries = currentEntries.merge @adds
       
            usedIds=[]
            # dump lines and placeholders
            aLines.each { |line|
                if line.respond_to? :mergedump
                    usedIds << line.mergedump( anIO, mergedEntries )
                else
                    anIO.puts line.to_s
                end
            }
            #dump new entries
            restIds  = mergedEntries.keys - usedIds
            restLines = restIds.map {|id| EntryPlaceholder.new id}
            restLines .each {|line| line.mergedump anIO, mergedEntries }
            mergedEntries
        end

    protected
        # override this if you want to get the cron definition from other sources
        def getInput
            if @input
                @input
            else 
                cmd = @user ? "crontab -u #{@user} -l" : "crontab -l"
                IO.popen(cmd)
            end        
        end

        # override this if you want to write the cron definition from other destination
        def getOutput
            if @output
                @output
            else 
                cmd = @user ? "crontab -u #{@user} -" : "crontab -"
                IO.popen(cmd,'w')
            end
        end
    
        attr_reader :adds, :removals
    end 

    # FileCrontab allows you to read in/write out crontab definitions from/to files. You might want to use it for merging some enire file to crontab.
    # If '-' is given instead of  input file / output file the definitions are streamed from/into STDIN/STDOUT. 
    #
    # Example:
    #       fc = FileCrontab.new 'crontemplate.txt', '/tmp/crontest.txt'
    #       fc.add 'agent', '59 * * * * echo "modified"'
    #       fc.remove 'agent2'
    #       fc.commit
    #
    # or create a crontab fron scratch and output to STDOUT
    #       fc = FileCrontab.new nil, '-'
    #       fc.add 'agent', '59 * * * * echo "modified"'
    #       fc.commit


    class FileCrontab < Crontab 
        # anInputFile and anOutputFile can be either filename - to r/w the file, '-' to use STDIN/STDOUT, or nil for no input/output
        def initialize anInputFile = nil, anOutputFile = nil
            super nil
            @input = anInputFile
            @opts[:close_input] = false if @input=='-'
            @output = anOutputFile
            @opts[:close_output] = false if @output=='-'
        end
    protected
        def getInput
            case @input
                when nil then StringIO.new
                when '-' then STDIN
                else File.open( @input, 'r' ) 
            end
        end

        def getOutput
            case @output
                when nil then StringIO.new
                when '-' then STDOUT
                else File.open( @output, 'w' ) 
            end
        end    
    end
    
    # DummyCrontab allows you to create crontab definitions from scratch and dump them out as string. (Or combine them with other Crontab definitions)
    #
    # Example:
    #       fc = DummyCrontab.new
    #       fc.add 'agent1', '59 * * * * echo "agent1"'
    #       fc.add 'agent2', {:hour=>'2',:command=>'echo "huh"'}
    #       fc.commit
    #       puts fc
    class DummyCrontab < Crontab 
        require 'stringio'
        def initialize
            super nil
            @buffer = StringIO.new
        end
    
        def to_s
            @buffer.string
        end
    
    protected
        def getInput
            #loopback - for multiple use
            StringIO.new @buffer.string
        end

        def getOutput
            @buffer = StringIO.new
        end    
    end
    # When the Crontab object reads in (parse) all lines, placeholder appears where a Crontab entry with an id was detected
    class EntryPlaceholder
        attr_reader :id
        def self.Create(aLine)
            id = ScanId aLine
            return id ? EntryPlaceholder.new(id) : nil
        end
        def self.ScanId aStr
            aStr.scan(/^\#\#__(.*)__/).flatten.first
        end
        def self.GenerateId anId
            "##__#{anId}__"
        end    
        def initialize anId
            @id = anId.to_s
        end
    
        #returns used id
        def mergedump anIO, anEntryHash
            entry = anEntryHash[@id]
            if entry
                anIO.puts "#{EntryPlaceholder.GenerateId @id}\n"
                anIO.puts "#{entry}\n"
                return @id
            else
                return nil
            end
        end
    end

    #A cron entry ...
    class CronEntry
        DEFAULTS = {
            :minute => '*',
            :hour => '*',
            :day => '*',
            :month => '*',
            :weekday => '*',
            :command => ''
        }

        class FormatError < StandardError; end
    
        # Hash def, or raw String def
        def initialize aDef = {}
            if aDef.kind_of? Hash  
                wrong = aDef.collect { |k,v| DEFAULTS.include?(k) ? nil : k}.compact
                raise "Wrong definition, invalid constructs #{wrong}" unless wrong.empty?
                @defHash = DEFAULTS.merge aDef
                # TODO: validate values
                @def = to_raw @defHash ;
            else
                @defHash = parseTextDef aDef
                @def = aDef;
            end
        end
        
        def to_s
            @def.freeze
        end
    
        def to_hash
            @defHash.freeze
        end
    
        def []aField
            @defHash[aField]
        end
    
        def to_raw aHash = nil;
            aHash ||= @defHash
            "#{aHash[:minute]}\t#{aHash[:hour]}\t#{aHash[:day]}\t#{aHash[:month]}\t"  +
                "#{aHash[:weekday]}\t#{aHash[:command]}"
        end
    
   private 
    
        # Parses a raw text definition of crontab entry
        # returns hash definition
        # Original author of parsing: gotoken@notwork.org
        def parseTextDef aLine
            hashDef = parse_timedate aLine
            hashDef[:command] = aLine.scan(/(?:\S+\s+){5}(.*)/).shift[-1]
            ##TODO: raise( FormatError.new "Command cannot be empty") if aDef[:command].empty?
            hashDef
        end
    
        # Original author of parsing: gotoken@notwork.org
        def parse_timedate str, aDefHash = {}
            minute, hour, day_of_month, month, day_of_week = 
                str.scan(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/).shift
            day_of_week = day_of_week.downcase.gsub(/#{WDAY.join("|")}/){
                WDAY.index($&)
            }
            aDefHash[:minute] = parse_field(minute,       0, 59)
            aDefHash[:hour] =  parse_field(hour,         0, 23)
            aDefHash[:day] =    parse_field(day_of_month, 1, 31)
            aDefHash[:month] =    parse_field(month,        1, 12)
            aDefHash[:weekday] =    parse_field(day_of_week,  0, 6)
            aDefHash
        end

        # Original author of parsing: gotoken@notwork.org
        def parse_field str, first, last
            list = str.split(",")
            list.map!{|r|
                r, every = r.split("/")
                every = every ? every.to_i : 1
                f,l = r.split("-")
                range = if f == "*"
                        first..last
                    elsif l.nil?
                        f.to_i .. f.to_i
                    elsif f.to_i < first
                        raise FormatError.new( "out of range (#{f} for #{first})")
                    elsif last < l.to_i
                        raise FormatError.new( "out of range (#{l} for #{last})")
                    else
                        f.to_i .. l.to_i
                  end
                range.to_a.find_all{|i| (i - first) % every == 0}
            }
            list.flatten!
            list.join ','
        end    

        WDAY = %w(sun mon tue wed thu fri sut)
    end

end 

if  __FILE__ == $0
    include CronEdit
end
