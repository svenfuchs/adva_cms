# Removes all cronjobs created by test
#
# after do
#   remove_all_test_cronjobs
# end
#
def remove_all_test_cronjobs
  CronEdit::Crontab.List.keys.each do |key|
    CronEdit::Crontab.Remove(key) if key =~ /test-/
  end
end
