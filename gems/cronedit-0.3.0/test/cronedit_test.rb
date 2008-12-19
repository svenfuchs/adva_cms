$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'cronedit.rb'
require 'stringio'
include CronEdit

class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    saved_protected_instance_methods = self.protected_instance_methods
    self.class_eval { public(*saved_private_instance_methods) }
    self.class_eval { public(*saved_protected_instance_methods) }
    yield
    self.class_eval { protected(*saved_protected_instance_methods) }
    self.class_eval { private(*saved_private_instance_methods) }
  end
end

class CronEdit_test < Test::Unit::TestCase
  def setup
        #backup crontab
        `crontab -l > /tmp/crontab.bak`
  end

  def teardown
        #restore crontab
        `crontab  /tmp/crontab.bak`
  end

    def test_idParsing
        idin=['##__id1__', '   ##__id3__', '#the end comment','kuk','##___id4___','###__id5__']
        out = idin.map {|l| CronEdit::EntryPlaceholder.ScanId(l)}
        assert_equal(['id1',nil,nil,nil,'_id4_',nil], out, "idParsing")
    end

    def test_creation
        e = CronEntry.new( "5,35 0-23/2 * * * echo 123" )
        assert_equal( '5,35 0-23/2 * * * echo 123', e.to_s )
    
        e = CronEntry.new
        assert_equal( "*\t*\t*\t*\t*\t", e.to_s, 'default' )

        e = CronEntry.new( {:minute=>5, :command=>'echo 42'} )
        assert_equal( "5\t*\t*\t*\t*\techo 42", e.to_s )
    
    end
    
    def test_parsing
        e = CronEntry.new( "5,35 0-23/2 * * * echo 123" )
        assert_equal( "5,35", e[:minute])
        assert_equal( "0,2,4,6,8,10,12,14,16,18,20,22", e[:hour])
        assert_equal( "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31", e[:day])
    end

    def test_wrongformat
        assert_raise(CronEntry::FormatError){
            CronEntry.new( "1-85 2 * * * echo 123" )
        }
    end

    def test_wrongconfog
        assert_raise(RuntimeError){
            CronEntry.new( {:minuteZ=>5, :command=>'echo 42'} )
        }
    end
  
    def test_zip
        Crontab.publicize_methods {
            crontabTest=%Q{
            5,35 0-23/2 * * * echo 123
            ##__agent1__
            3 * * * * echo agent1


            ##__agent2__
            3 * * * * echo agent2
            #ignored comment
            ##__agent1__
            3 * * * * echo agent3
        }
            expected = {"agent1"=>"3 * * * * echo agent3", "agent2"=>"3 * * * * echo agent2", "1"=>"5,35 0-23/2 * * * echo 123"}
            assert_equal( expected, Crontab.new.parseCrontab(crontabTest), 'parsing of crontab file')
        }
    end

    def test_emptycrontab
        input = 'no crontab for user'
        assert_equal( {}, Crontab.new.setIO(StringIO.new(input),nil).list )
    end

    def test_clear
        Crontab.new.clear!
        entries, lines = Crontab.new.listFull
        assert_equal( {}, entries,  "Entries"    )
        Crontab.new.list
    end

    def test_rollback
        #rollback test
        `crontab -r`; `crontab -d`
        assert_equal( {}, Crontab.new.list, 'precondition' )
        cm = Crontab.new
        cm. add 'agent1', '5,35 0-23/2 * * * "echo 123" '
        cm.remove "agent2"
        #cm.review
        cm.rollback
        assert_equal( {}, Crontab.new.list )
    end

    def test_complex
        Crontab.publicize_methods {
            File.open( File.join(File.dirname(__FILE__), 'testcron.txt') ) { |f|
                content = f.read
                f.rewind
                entries, lines = Crontab.new.parseCrontabFull f
                assert_equal 12, lines.length, "Lines"
                assert_equal ['1','2','3','test'].sort, entries.keys.sort, "Entries"
                #puts "--------------Lines:  \n#{lines.join("\n") }"
                #puts "--------------entries:  \n#{entries.map {|k,v| "#{k}=>#{v}\n"} }"
                output = StringIO.new
                Crontab.new.dumpCron  entries, lines, output
                #puts "OUT: #{output.string}"
                #loop
                output.rewind
                entries2, lines2 = Crontab.new.parseCrontabFull output
                assert_equal 12, lines2.length, "Lines2"
                assert_equal ['1','2','3','test'].sort, entries2.keys.sort, "Entries2"
            }
        }
    end

    def test_complex2
        crontabTest=%Q{
    MAIL = user
    ##__agent1__
    3 * * * * echo agent1

    
    #comment
    3 * * * * echo agent2
    
    ##__blankId__
    #anonymous
    3 * * * * echo anonymous
    }
        ct = Crontab.new
        ct.setIO StringIO.new(crontabTest), nil
        entries, lines = ct.listFull
        assert_equal 11, lines.length, "Lines"
        assert_equal ['agent1','1','2'].sort, entries.keys.sort, "Entries"
##        puts "--------------Lines:  \n#{lines.join("\n") }"
##        puts "--------------entries:  \n#{entries.map {|k,v| "#{k}=>#{v}\n"} }"

        ct.add 'agent1', '5,35 0-23/2 * * * echo agent1'   #overwriting
        ct.add 'agent3', '0 2 * * * echo agent3'   #new agent
        ct.remove '2'
        output = StringIO.new
        ct.setIO StringIO.new(crontabTest), output
        ct.commit
##        puts '-'*40 + "\n#{output.string}\n" + '-'*40
        # loop
        ct.setIO StringIO.new(output.string), nil
        entries, lines = ct.listFull
        assert_equal 11, lines.length, "Lines"
        assert_equal ['agent1','agent3','1'].sort, entries.keys.sort, "Entries"
##        puts "--------------Lines:  \n#{lines.join("\n") }"
##        puts "--------------entries:  \n#{entries.map {|k,v| "#{k}=>#{v}\n"} }"
    end

    def test_commit
            `crontab -r`; `crontab -d`
            assert_equal( {}, Crontab.new.list, 'precondition' )
            cm = Crontab.new
            cm. add "agent1", "5,35 0-23/2 * * * echo agent1" 
            cm. add "agent2", "0 2 * * * echo agent2" 
            cm.commit
            current=cm.list
            expected = {"agent1"=>"5,35 0-23/2 * * * echo agent1", "agent2"=>"0 2 * * * echo agent2"}
            assert_equal( expected, current, 'first commit' )
    
            cm = Crontab.new
            cm. add "agent1", '59 * * * * echo "modified agent1"'
            cm.remove "agent2"
            cm.commit
            current = cm.list
            expected = {"agent1"=>"59 * * * * echo \"modified agent1\""}
            assert_equal( expected, current, 'second commit' )
    
            Crontab.Remove "agent1"
            assert_equal( {}, Crontab.List, 'precondition' )
    end

    def test_classMethods
        Crontab.List
    end

    def test_filecrontab
        fc = FileCrontab.new File.join(File.dirname(__FILE__), 'testcron.txt'), '/tmp/crontest.txt'
        fc.add 'file', '59 * * * * echo "file"'
        fc.remove 2, 3
        fc.commit
        # check it
        entries, lines = FileCrontab.new( '/tmp/crontest.txt',nil).listFull
        assert_equal 11, lines.length, "Lines"
        assert_equal ['1','test','file'].sort, entries.keys.sort, "Entries"
    end

    def test_filecrontab2
        fc = FileCrontab.new nil,  '-'
        fc.add 'agent', '59 * * * * echo 123'
        fc.commit
        #todo: how to test STDOUT

        fc = FileCrontab.new nil,  '/tmp/crontest.txt'
        fc.add 'agent', '59 * * * * echo 123'
        fc.commit
        File.open( '/tmp/crontest.txt') {
            |f|
            assert_equal f.read, "##__agent__\n59 * * * * echo 123\n"
        }
    end

    def test_dummycrontab
        fc = DummyCrontab.new
        fc.add 'agent1', '59 * * * * echo "agent1"'
        fc.add 'agent2', {:hour=>'2',:command=>'echo "huh"'}
        fc.commit
        #check 1
        output = fc.to_s
        entries, lines = Crontab.new.setIO(StringIO.new(output),nil).listFull
        assert_equal 2, lines.length, "Lines"
        assert_equal ['agent1','agent2'].sort, entries.keys.sort, "Entries"
        #continue editing
        fc.remove 'agent2'
        fc.commit
        #check 2
        output = fc.to_s
        entries, lines = Crontab.new.setIO(StringIO.new(output),nil).listFull
        assert_equal 1, lines.length, "Lines"
        assert_equal ['agent1'].sort, entries.keys.sort, "Entries"
    end

    def test_merge
        fc1 = DummyCrontab.new
        fc1.add 'agent1', '59 * * * * echo "agent1"'
        fc1.add 'agent2', {:hour=>'2',:command=>'echo "huh"'}
        fc1.commit
    
        fc2 = DummyCrontab.new
        fc2.add 'agent3', '59 * * * * echo "agent3"'
        fc2.remove 'agent2'
        
        fc1.merge fc2
        fc1.commit
        output = fc1.to_s
        entries, lines = Crontab.new.setIO(StringIO.new(output),nil).listFull
        assert_equal 2, lines.length, "Lines"
        assert_equal ['agent1','agent3'].sort, entries.keys.sort, "Entries"    
    end

    def test_mergeWithFile
        fc1 = FileCrontab.new File.join(File.dirname(__FILE__), 'testcron.txt')
    
        fc2 = DummyCrontab.new
        fc2.add 'agent3', '59 * * * * echo "agent3"'
        
        fc2.merge fc1
        fc2.commit
        output = fc2.to_s
##        puts "\n\n"+output
        entries, lines = Crontab.new.setIO(StringIO.new(output),nil).listFull
        assert_equal 5, lines.length, "Lines"
        assert_equal ['1','2','3','test','agent3'].sort, entries.keys.sort, "Entries"    
    end

    def test_subtractFile
        fc1 = DummyCrontab.new
        fc1.add 'test', '59 * * * * echo "whatever"'
        fc1.add 'test2', '59 * * * * echo "whatever"'
        fc1.add '3', '59 * * * * echo "whatever"'
        fc1.commit

    
        fc2= FileCrontab.new File.join(File.dirname(__FILE__), 'testcron.txt')
        fc1.subtract fc2
        fc1.commit
        output = fc1.to_s
##        puts "\n\n"+output
        entries, lines = Crontab.new.setIO(StringIO.new(output),nil).listFull
        assert_equal 1, lines.length, "Lines"
        assert_equal ['test2'].sort, entries.keys.sort, "Entries"    
    end

end
