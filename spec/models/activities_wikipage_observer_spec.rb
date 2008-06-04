require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::WikipageObserver do
  include SpecActivityHelper
  include Stubby

  before :each do
    scenario :site, :section, :user
    
    @wikipage = Wikipage.new :author => @user
    methods = { :id => 1, :section_id => 1, :site_id => 1, :title => 'title',  :type => 'Wikipage' }
    methods.each do |method, result|
      @wikipage.stub!(method).and_return result
    end
  end
  
  it "should log a 'created' activity on save when the wikipage is a new_record" do
    expect_activity_new_with :actions => ['created']
    Wikipage.with_observers('activities/wikipage_observer') { @wikipage.save! }
  end
  
  it "should log a 'revised' activity on save when the wikipage already exists and will save a new version" do
    expect_activity_new_with :actions => ['revised']
    Wikipage.with_observers('activities/wikipage_observer') { revised(@wikipage).save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    expect_activity_new_with :actions => ['deleted']
    Wikipage.with_observers('activities/wikipage_observer') { destroyed(@wikipage).destroy }
  end
end