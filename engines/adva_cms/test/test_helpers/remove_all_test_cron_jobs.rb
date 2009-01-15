# Removes all crontab jobs created by test
#
def remove_all_test_cron_jobs
  CronEdit::Crontab.List.keys.each do |key|
    CronEdit::Crontab.Remove(key) if key =~ /test-/
  end
end
