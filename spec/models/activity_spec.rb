require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before :each do
    attributes = {:object_type => 'foo', :object_id => 1}
    @activity = Activity.new attributes.update(:actions => ['edited', 'revised'], :created_at => Time.zone.now)
    @others = [10, 70, 80].collect do |minutes_ago| 
      actions = minutes_ago == 80 ? ['created'] : ['edited']
      Activity.new attributes.update(:actions => actions, :created_at => minutes_ago.minutes.ago)
    end    

    @yesterdays = [Activity.new(attributes.update(:created_at => 1.day.ago))]
    @older = [Activity.new(attributes.update(:created_at => 2.days.ago))]
    
    @activities = [@activity] + @others + @yesterdays + @older
    @activities.sort!{|left, right| right.created_at <=> left.created_at }
  end
  
  describe '#find_coinciding_grouped_by_dates' do
    it "should find coinciding activities grouped by given dates" do
      Activity.should_receive(:find).and_return @activities      
      today, yesterday = Time.zone.now.to_date, 1.day.ago.to_date
      result = Activity.find_coinciding_grouped_by_dates today, yesterday
      result.should == [[@activity], @yesterdays, @older]
    end
  end

  describe '#find_coinciding' do
    it "should find activities and group them to chunks coninciding within a given time delta (hiding grouped activities under @activity.siblings)" do
      Activity.should_receive(:find).and_return [@activity] + @others
      result = Activity.find_coinciding
      result.should == [@activity]
      result.first.siblings.should == @others
    end
  end

  describe '#coincides_with?(other)' do
    it "should return true when it's own and the other object's created_at values difference is smaller or equal to the given delta value" do
      @activity.coincides_with?(@others.first).should be_true
    end
    
    it "should return true when it's own and the other object's created_at values difference is greater than the given delta value" do
      @activity.coincides_with?(@others.last).should be_false
    end
  end

  describe '#from' do
    it "should return the last sibling's created_at value" do
      @activity.siblings = @others
      @activity.from.should == @others.last.created_at
    end
  end

  describe '#to' do
    it "should return its created_at value" do
      @activity.siblings = @others
      @activity.to.should == @activity.created_at
    end
  end
  
  describe '#all_actions' do
    it "should return all actions from all siblings in a chronological order" do
      @activity.siblings = @others
      @activity.all_actions.should == ['created', 'edited', 'edited', 'edited', 'revised']
    end
  end

  describe "after initialized" do
    it "should have an empty array set as siblings" do
      Activity.new.siblings.should == []
    end
  end
  
  describe "for missing methods" do
    it "should check it's object_attributes hash's keys" do
      @activity.should_receive(:[]).with(:object_attributes).and_return 'foo' => 'bar'
      @activity.foo.should == 'bar'
    end
  end
end