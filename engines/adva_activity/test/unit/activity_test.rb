require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ActivityTest < ActiveSupport::TestCase
  setup :bunch_of_activities
  
  test 'associations' do
    @activity.should belong_to(:site)
    @activity.should belong_to(:section)
    @activity.should belong_to(:object, :polymorphic => true)
    @activity.should belong_to(:author)
  end
  
  test 'validations' do
    @activity.should validate_presence_of(:site)
    @activity.should validate_presence_of(:section)
    @activity.should validate_presence_of(:object)
  end
  
  # CLASS METHODS
  
  test '#find_coinciding_grouped_by_dates finds coinciding activities grouped 
        by given dates' do
    stub(Activity).find.returns @activities
    today, yesterday = Time.zone.now.to_date, 1.day.ago.to_date
    result = Activity.find_coinciding_grouped_by_dates today, yesterday
    result.should == [[@activity], @yesterdays, @older]
  end
  
  test '#find_coinciding finds activities and groups them to chunks coninciding 
        within a given time delta, hiding grouped activities in @activity.siblings' do
    stub(Activity).find.returns [@activity] + @others
    result = Activity.find_coinciding
    result.should == [@activity]
    result.first.siblings.should == @others
  end
  
  # INSTANCE METHODS
  
  test "#coincides_with?(other) is true when the compared created_at values 
        differ by less/equal to the given delta value" do
    @activity.coincides_with?(@others.first).should be_true
  end

  test "#coincides_with?(other) is false when the compared created_at values 
        differ by more than the given delta value" do
    @activity.coincides_with?(@others.last).should be_false
  end
  
  test "#from returns the last sibling's created_at value" do
    @activity.siblings = @others
    @activity.from.should == @others.last.created_at
  end

  test "#to return the activity's created_at value" do
    @activity.siblings = @others
    @activity.to.should == @activity.created_at
  end

  test "#all_actions returns all actions from all siblings in a chronological order" do
    @activity.siblings = @others
    @activity.all_actions.should == ['created', 'edited', 'revised']
  end
  
  test "when a missing method is called it looks for a corresponding key in object_attributes" do
    @activity.object_attributes = { 'foo' => 'bar' }
    @activity.foo.should == 'bar'
  end

  
  def bunch_of_activities
    attributes = {:object_type => 'Article', :object_id => 1}
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
end