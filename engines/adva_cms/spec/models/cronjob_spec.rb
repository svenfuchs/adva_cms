require File.dirname(__FILE__) + '/../spec_helper'

describe Cronjob do
  before do
    @cronjob = Factory :cronjob
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
    
    it "should have unique cron_id" do
      #TODO
    end
  end
  
  describe "methods" do
    describe "full_id" do
      it "should provide 'test-' prefix when in test mode" do
        @cronjob.full_id.should == "test-#{RAILS_ROOT}--#{@cronjob.id}"
      end
      
      it "should include cron_id into full_id" do
        @cronjob.cron_id = "email-deliver-all"
        @cronjob.full_id.should == "test-#{RAILS_ROOT}-email-deliver-all-#{@cronjob.id}"
      end
    end
    
    describe "runner_command" do
      it "should return full runner command with gem path, ruby, command and WITHOUT autoclean" do
        @cronjob.runner_command.should == 
          "export GEM_PATH=#{ENV['GEMDIR']}; " +
          "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; '"
      end

      it "should return full runner command with gem path, ruby, command and WITH autoclean" do
        @cronjob.due_at = DateTime.now
        @cronjob.runner_command.should == 
          "export GEM_PATH=#{ENV['GEMDIR']}; " +
          "#{ruby_path} -rubygems #{RAILS_ROOT}/script/runner -e test 'test_command; " +
          "Cronjob.find(#{@cronjob.id}).destroy;'"
      end
    end
    
    describe "due_at=" do
      it "should accept datetime hash and update cronjob fields" do
        @cronjob.due_at = {:minute => "01", :hour => "01", :day => "01", :month => "01"}
        @cronjob.minute.should == "01"
        @cronjob.hour.should == "01"
        @cronjob.day.should == "01"
        @cronjob.month.should == "01"
      end
      
      it "should accept DateTime object and update cronjob fields" do
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

describe Cronjob do
  before do
    @cronjob = Factory.build :cronjob
  end
  
  describe "save" do
    it "should create CronEdit cronjob" do
      @cronjob.save
      @jobs = `crontab -l`
      @jobs.should =~ cronjob_regexp(@cronjob)
    end
  end
  
  describe "destroy" do
    it "should remove CronEdit cronjob" do
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
  /#{ Regexp.escape("##__test-#{RAILS_ROOT}--#{model.id}__\n*\t*\t*\t*\t*\texport GEM_PATH") }/
end

def ruby_path
  File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])
end
