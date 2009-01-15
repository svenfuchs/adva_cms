class CronJob < ActiveRecord::Base
  belongs_to :cronable, :polymorphic => true
  
  validates_presence_of :command
  
  after_save :create_crontab
  after_destroy :remove_crontab
  
  def create_crontab
    CronEdit::Crontab.Add self.test_aware_id, {:command => self.runner_command}
  end
  
  def remove_crontab
    CronEdit::Crontab.Remove self.test_aware_id
  end

  def runner_command
    "export GEM_PATH=#{ENV["GEMDIR"]}; " +
    "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e #{RAILS_ENV} " +
    "'#{self.command}; #{autoclean}'"
  end

  #TODO: CronEdit needs rewrite
  def test_aware_id
    RAILS_ENV == 'test' ? "test-#{self.id}" : self.id
  end
  
private
  
  def autoclean
    "CronJob.find(#{self.id}).destroy;" if self.due_at.present?
  end
  
  def ruby_path
    File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
  end
end
