class Adva::Cronjob < ActiveRecord::Base
  set_table_name "adva_cronjobs"

  belongs_to :cronable, :polymorphic => true
  
  attr_accessible :command, :due_at, :cron_id
  validates_presence_of :command
  validates_uniqueness_of :cron_id
  
  after_save :create_crontab
  after_destroy :remove_crontab
  
  # Handy shortcut to create cronjob using DateTime object as due time.
  # DateTime argument will be converted to localtime because cronjobs needs same zone as OS.
  #
  # Example:
  # Cronjob.new :command => "Email.destroy_all", :due_at => (Time.zone.now + 10.minutes)
  #
  def due_at=(datetime)
    if datetime.present?
      localtime = datetime.class == ActiveSupport::TimeWithZone ? datetime.localtime : datetime
      self.minute  = localtime.min.to_s
      self.hour    = localtime.hour.to_s
      self.day     = localtime.day.to_s
      self.month   = localtime.month.to_s
      self.weekday = "*"
    end
  end
  
  def due_at
    @exact_due_time_check = []
    [self.minute,self.hour,self.day,self.month].each do |time|
      @exact_due_time_check << !(time =~ /[\*\/\-]/) || !time.nil?
    end
    @exact_due_time_check << (self.weekday == "*")

    if @exact_due_time_check.include? false
      nil
    else
      DateTime.new Date.today.year, self.month.to_i, self.day.to_i, self.hour.to_i, self.minute.to_i
    end
  end
  
  def full_id
    RAILS_ENV == 'test' ? "test-#{RAILS_ROOT}-#{self.cron_id}-#{self.id}" : "#{RAILS_ROOT}-#{self.cron_id}-#{self.id}"
  end

  def create_crontab
    CronEdit::Crontab.Add self.full_id, { :command => self.runner_command,
                                          :minute => self.minute,
                                          :hour => self.hour,
                                          :day => self.day,
                                          :month => self.month,
                                          :weekday => self.weekday }
  end
  
  def remove_crontab
    CronEdit::Crontab.Remove self.full_id
  end

  def runner_command
    "export GEM_PATH=#{Gem.path.join(":")}; " +
    "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e #{RAILS_ENV} " +
    "'#{self.command}; #{autoclean}'"
  end
  
private
  
  def autoclean
    "Adva::Cronjob.find(#{self.id}).destroy;" if self.due_at.present?
  end
  
  def ruby_path
    File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
  end
end
