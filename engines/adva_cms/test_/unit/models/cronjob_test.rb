require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

# FIXME something needs to be stubbed here. this seems to have spawed hundreds of
# Ruby processes bringing my machine almost completely to halt.
#
# It leaves a bunch of cronjobs in my crontab ... which curiously doesn't even seem
# to be saved to a file?
#
# Ok, figured it out. The second test class contained a teardown cleanup hook which
# I had commented out because I wanted to focus on the first class. Well, this still
# seems dangerous to me. What if that hook never gets called for some reason.
#
# There's a DummyCrontab class in cronedit, maybe one could use that?

class CronjobTest < ActiveSupport::TestCase
  def setup
    super
    # FIXME move to database/populate
    Cronjob.delete_all
    @cronjob = Cronjob.create! :command => "test_command"
  end
  
  teardown do
    remove_all_test_cronjobs
  end

  test "a cronjob with a command is valid" do
    # FIXME implement matcher
    # @cronjob.should be_valid
    assert @cronjob.valid?
  end

  test "a cronjob is valid without a due_at date" do
    # FIXME implement matcher
    @cronjob.due_at = nil
    assert @cronjob.valid?
  end

  test "a cronjob must have a command" do
    # FIXME implement matcher
    @cronjob.command = nil
    assert !@cronjob.valid?
  end

  test "should have unique cron_id" do
    #TODO
  end

  # full_id
  test "full_id provides 'test-' prefix when in test mode" do
    @cronjob.full_id.should == "test-#{RAILS_ROOT}--#{@cronjob.id}"
  end

  test "full_id includes cron_id into full_id" do
    @cronjob.cron_id = "email-deliver-all"
    @cronjob.full_id.should == "test-#{RAILS_ROOT}-email-deliver-all-#{@cronjob.id}"
  end

  # runner_command
  test "runner_command returns full runner command with gem path, ruby, command and WITHOUT autoclean" do
    @cronjob.runner_command.should ==
      "export GEM_PATH=#{ENV['GEMDIR']}; " +
      "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; '"
  end

  test "runner_command returns full runner command with gem path, ruby, command and WITH autoclean" do
    @cronjob.due_at = DateTime.now
    @cronjob.runner_command.should ==
      "export GEM_PATH=#{ENV['GEMDIR']}; " +
      "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; " +
      "Cronjob.find(#{@cronjob.id}).destroy;'"
  end

  # due_at=
  test "due_at= accepts datetime hash and update cronjob fields" do
    @cronjob.due_at = {:minute => "01", :hour => "01", :day => "01", :month => "01"}
    @cronjob.minute.should == "01"
    @cronjob.hour.should == "01"
    @cronjob.day.should == "01"
    @cronjob.month.should == "01"
  end

  test "due_at= accepts DateTime object and update cronjob fields" do
    @cronjob.due_at = DateTime.new 2009,01,15,10,30
    @cronjob.minute.should == "30"
    @cronjob.hour.should == "10"
    @cronjob.day.should == "15"
    @cronjob.month.should == "1"
  end

  # due_at
  test "due_at is nil when there is no exact due-time" do
    @cronjob.due_at.should == nil
  end

  test "due_at is a DateTime" do
    @cronjob.due_at = {:minute => "01", :hour => "01", :day => "01", :month => "01"}
    @cronjob.due_at.should == DateTime.new(Date.today.year, 1, 1, 1, 1)
  end

  test "due_at is nil when there is multiple times" do
    @cronjob.due_at = {:minute => "10/5", :hour => "01", :day => "01", :month => "01"}
    @cronjob.due_at.should == nil
    @cronjob.due_at = {:minute => "5-10", :hour => "01", :day => "01", :month => "01"}
    @cronjob.due_at.should == nil
  end
  
  # FIXME regex does not match:
  # "##__test-/Users/sven/Development/projects/adva-cms/adva-cms--136__\n*\t*\t*\t*\t*\texport GEM_PATH=; /usr/local/bin/ruby -rubygems /Users/sven/Development/projects/adva-cms/adva-cms/script/runner -e test 'test_command; '\n" =~ 
  # /\#\#__test\-\/Users\/sven\/Development\/projects\/adva\-cms\/adva\-cms\-\-__\n\*\t\*\t\*\t\*\t\*\texport\ GEM_PATH/. /\#\#__test\-\/Users\/sven\/Development\/projects\/adva\-cms\/adva\-cms\-\-__\n\*\t\*\t\*\t\*\t\*\texport\ GEM_PATH/
  #
  # # create
  # 
  # test "create should create CronEdit cronjob" do
  #   cronjob = Cronjob.new :command => "test_command"
  #   cronjob.save
  #   jobs = `crontab -l`
  #   jobs.should =~ cronjob_regexp(cronjob)
  # end
  # 
  # # destroy
  # 
  # test "destroy should remove CronEdit cronjob" do
  #   cronjob = Cronjob.new :command => "test_command"
  #   cronjob.save
  #   cronjob.destroy
  #   jobs = `crontab -l`
  #   (jobs =~ cronjob_regexp(cronjob)).should == nil
  # end
end

def cronjob_regexp(model)
  /#{ Regexp.escape("##__test-#{RAILS_ROOT}--#{model.id}__\n*\t*\t*\t*\t*\texport GEM_PATH") }/
end

def ruby_path
  File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
end
