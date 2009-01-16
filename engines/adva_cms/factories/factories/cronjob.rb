Factory.define :cronjob do |c|
  c.command "test_command"
end

Factory.define :cronjob_with_exact_due_datetime, :class => Cronjob do |c|
  c.command "test_command"
  c.due_at DateTime.new(2008,01,15,20,00)
end
