require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

if Rails.plugin?(:adva_activity)
  class ActivitiesWikipageObserverTest < ActiveSupport::TestCase
    def setup
      super
      Wikipage.old_add_observer(@observer = Activities::WikipageObserver.instance)
      @wikipage = Wikipage.first
    end
  
    def teardown
      super
      Wikipage.delete_observer(@observer)
    end

    test "logs a 'created' activity when the wikipage is a new_record" do
      wikipage = Wikipage.create! :title => 'title', :body => 'body', :author => User.first,
                                  :site => Site.first, :section => Section.first
      wikipage.activities.first.actions.should == ['created']
    end

    test "logs a 'revised' activity when the wikipage is revised" do
      @wikipage.update_attributes! :body => 'body was revised'
      @wikipage.activities.first.actions.should == ['revised']
    end

    test "logs a 'deleted' activity on destroy" do
      @wikipage.destroy
      @wikipage.activities.first.actions.should == ['deleted']
    end
  end
end