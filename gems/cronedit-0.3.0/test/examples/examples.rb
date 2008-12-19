$:.unshift File.join(File.dirname(__FILE__),'../..','lib')
require 'cronedit.rb' 
include CronEdit

# 1. Direct cron modifications
Crontab.Add  'agent1', '5,35 0-23/2 * * * echo agent1'
Crontab.Add  'agent2', {:minute=>5, :command=>'echo 42'}
p Crontab.List
Crontab.Remove 'agent1', 'agent2'

# 2. Batch modification
cm = Crontab.new
cm.add :agent1, '5,35 0-23/2 * * * echo "agent1" >> /tmp/agent/log'
cm.add :agent2, {:minute=>5, :command=>'echo 42'}
cm.commit
p cm.list


#3. Delete crontab completely
cm.clear!

# 4. Bulk merge from file using FileCrontab
fc = FileCrontab.new File.join(File.dirname(__FILE__), 'example1.cron')
# Add all entries from file
Crontab.Merge fc
p Crontab.List
# An an entry manually
Crontab.Add  :test, '* * * * * test'
# Remove all entries defined in the file
Crontab.Subtract fc
p Crontab.List 

# 5. Read from file - output to STDOUT (you can use a file instead of STDOUT)
fc = FileCrontab.new File.join(File.dirname(__FILE__), 'example1.cron'), '-'
fc.add :agent2, {:minute=>5, :command=>'echo 42'}
fc.commit


# 6. DummyCrontab - in memory crontab
dc = DummyCrontab.new
dc.add 'agent1', '59 * * * * echo "agent1"'
dc.add 'agent2', {:hour=>'2',:command=>'echo "huh"'}
dc.commit
puts dc

# 7. Of course you can combine (merge/subtract) all types of Crontabs, ie. Crontab, FileCrontab, DummyCrontab

# 8. In case you need to read/write crontab definition from/to yet another source (stream) use setIO method
require 'stringio'
output = "#read from DB"
p Crontab.new.setIO(StringIO.new(output),nil).list
