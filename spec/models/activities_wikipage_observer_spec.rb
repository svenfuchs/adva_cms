require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::WikipageObserver do
  include SpecActivityHelper
  include Stubby

  it "should log a 'created' activity on save when the wikipage is a new_record" do
    # wtf ... can not use the scenario :wikipage_created here for some reason
    # sqlite breaks with a logic error
    @wikipage = Wikipage.new :author => stub_user,
                             :site => stub_site,
                             :section => stub_section,
                             :title => 'title', :body => 'body'

    expect_activity_new_with :actions => ['created']
    Wikipage.with_observers('activities/wikipage_observer') { @wikipage.save! }
  end

  it "should log a 'revised' activity on save when the wikipage already exists and will save a new version" do
    scenario :wikipage_revised
    expect_activity_new_with :actions => ['revised']
    Wikipage.with_observers('activities/wikipage_observer') { @wikipage.save! }
  end

  it "should log a 'deleted' activity on destroy" do
    scenario :wikipage_destroyed
    expect_activity_new_with :actions => ['deleted']
    Wikipage.with_observers('activities/wikipage_observer') { @wikipage.destroy }
  end
end


