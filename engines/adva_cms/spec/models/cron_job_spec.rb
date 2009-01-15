require File.dirname(__FILE__) + '/../spec_helper'

describe CronJob do
  before do
    @cronjob = Factory :cron_job
  end

  describe "validations:" do
    it "should be valid" do
      @cronjob.should be_valid
    end

    it "may have due at" do
      @cronjob.due_at = nil
      @cronjob.should be_valid
    end
    
    it "should have command" do
      @cronjob.command = nil
      @cronjob.should_not be_valid
    end
  end
  
  describe "methods" do
    describe "test_aware_id" do
      it "should provide different id when in test mode" do
        @cronjob.test_aware_id.should == "test-#{@cronjob.id}"
      end
    end
    
    describe "runner_command" do
      it "should return full runner command with gem path, ruby, command and autoclean" do
        @cronjob.runner_command.should == 
          "export GEM_PATH=#{ENV['GEMDIR']}; " +
          "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; " +
          "CronJob.find(#{@cronjob.id}).destroy;'"
      end
    end
    
    describe "due_at=" do
      it "should accept datetime hash and update cron job fields" do
        @cronjob.due_at = {:minute => "01", :hour => "01", :day => "01", :month => "01"}
        @cronjob.minute.should == "01"
        @cronjob.hour.should == "01"
        @cronjob.day.should == "01"
        @cronjob.month.should == "01"
      end
      
      it "should accept DateTime object and update cron job fields" do
        @cronjob.due_at = DateTime.new 2009,01,15,10,30
        @cronjob.minute.should == "30"
        @cronjob.hour.should == "10"
        @cronjob.day.should == "15"
        @cronjob.month.should == "1"
      end
    end
    
    describe "due_at" do
      it "should be nil when there is no exact due-time" do
        @cronjob.due_at.should == nil
      end

      it "should show provide DateTime" do
        @cronjob.due_at = {:minute => "01", :hour => "01", :day => "01", :month => "01"}
        @cronjob.due_at.should == DateTime.new(Date.today.year, 1, 1, 1, 1)
      end
      
      it "should be nil when there is multiple times" do
        @cronjob.due_at = {:minute => "10/5", :hour => "01", :day => "01", :month => "01"}
        @cronjob.due_at.should == nil
        @cronjob.due_at = {:minute => "5-10", :hour => "01", :day => "01", :month => "01"}
        @cronjob.due_at.should == nil
      end
    end
  end
end

describe CronJob do
  before do
    @cronjob = Factory.build :cron_job
  end
  
  describe "save" do
    it "should create CronEdit cron job" do
      @cronjob.save
      @jobs = `crontab -l`
      @jobs.should =~ cronjob_regexp(@cronjob)
    end
  end
  
  describe "destroy" do
    it "should remove CronEdit cron job" do
      @cronjob.save
      @cronjob.destroy
      @jobs = `crontab -l`
      (@jobs =~ cronjob_regexp(@cronjob)).should == nil
    end
  end

  after do
    remove_all_test_cronjobs
  end
end

def cronjob_regexp(model)
  /#{ Regexp.escape("##__test-#{model.id}__\n*\t*\t*\t*\t*\texport GEM_PATH") }/
end

def ruby_path
  File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
end
