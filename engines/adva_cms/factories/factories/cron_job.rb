Factory.define :cron_job do |c|
  c.command "test_command"
  c.due_at Time.now
end
