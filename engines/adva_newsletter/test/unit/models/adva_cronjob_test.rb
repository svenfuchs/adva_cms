require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

#TODO: There's a DummyCrontab class in cronedit, maybe one could use that?
class AdvaCronjobTest < ActiveSupport::TestCase
  def setup
    super
    @cronjob = Adva::Cronjob.create! :command => "test_command"
  end

  def teardown
    super
    remove_all_test_cronjobs
  end

  test "associations" do
    @cronjob.should belong_to(:cronable, :as => :polymorphic)
  end

  test "validations" do
    @cronjob.should be_valid
    @cronjob.should validate_presence_of(:command)
    @cronjob.should validate_uniqueness_of(:cron_id)
    @cronjob.should_not validate_presence_of(:due_at)
  end

  test "default values" do
    cronjob = Adva::Cronjob.new
    cronjob.command.should == nil
    cronjob.due_at.should == nil
    cronjob.minute.should == "*"
    cronjob.hour.should == "*"
    cronjob.day.should == "*"
    cronjob.month.should == "*"
  end

  test "#full_id should return 'test-' prefix when in test mode" do
    @cronjob.full_id.should == "test-#{RAILS_ROOT}--#{@cronjob.id}"
  end

  test "#full_id should return cron_id included" do
    @cronjob.cron_id = "email-deliver-all"
    @cronjob.full_id.should == "test-#{RAILS_ROOT}-email-deliver-all-#{@cronjob.id}"
  end

  test "#runner_command should return full runner command WITHOUT autoclean)" do
    @cronjob.runner_command.should ==
      "export GEM_PATH=#{Gem.path.join(":")}; " +
      "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; '"
  end

  test "#runner_command should return full runner command WITH autoclean" do
    @cronjob.due_at = DateTime.now
    @cronjob.runner_command.should ==
      "export GEM_PATH=#{Gem.path.join(":")}; " +
      "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; " +
      "Adva::Cronjob.find(#{@cronjob.id}).destroy;'"
  end

  test "#due_at should return DateTime" do
    @cronjob.due_at = Time.now
    @cronjob.due_at.should be_a(DateTime)
  end

  test "#due_at should return nil when cronjob does not have one due time" do
    @cronjob.due_at.should be_nil
  end

  test "#due_at should return nil when there is multiple times" do
    @cronjob.due_at = Time.now
    @cronjob.due_at.should_not be_nil
    @cronjob.minute = "10/5"
    @cronjob.due_at.should be_nil
    @cronjob.minute = "5-10"
    @cronjob.due_at.should be_nil
  end

  test "#due_at= should accept DateTime object and update cronjob fields" do
    @cronjob.due_at = DateTime.new 2009,01,15,10,30
    @cronjob.minute.should == "30"
    @cronjob.hour.should == "10"
    @cronjob.day.should == "15"
    @cronjob.month.should == "1"
  end

  test "#due_at= should convert TimeWithZone to localtime so cronjob will be at same timezone as OS" do
    @time_in_user_time_zone = Time.zone.local(2011,1,1, 1,1,1).in_time_zone(10)
    mock(@time_in_user_time_zone).class { ActiveSupport::TimeWithZone }
    mock(@time_in_user_time_zone).localtime { Time.utc(2011,1,1, 1,1,1) } # mock return OS timezone time

    Time.zone = -3 # just in case let's change timezone

    @cronjob.due_at = @time_in_user_time_zone
    @cronjob.minute.should == "1"
    @cronjob.hour.should == "1" # should be in the OS time zone and NOT user's one
    @cronjob.day.should == "1"
    @cronjob.month.should == "1"
  end

  test "#create should create CronEdit cronjob" do
    Adva::Cronjob.destroy_all
    cronjob = Adva::Cronjob.create!(:command => "test_command")
    `crontab -l`.should =~ cronjob_regexp(cronjob.id)
  end

  test "#destroy should remove CronEdit cronjob" do
    @cronjob.destroy
    `crontab -l`.should_not =~ cronjob_regexp(@cronjob.id)
  end
end

def cronjob_regexp(model_id)
  /#{ Regexp.escape("##__test-#{RAILS_ROOT}--#{model_id}__\n*\t*\t*\t*\t*\t") }/
end

def ruby_path
  File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
end
