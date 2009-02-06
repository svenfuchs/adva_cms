require File.dirname(__FILE__) + '/../../test_helper'

class DeletedNewsletterTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @deleted_newsletter = DeletedNewsletter.create! :title => "deleted newsletter title", 
                                                    :desc => "deleted newsletter desc",
                                                    :deleted_at => Time.now,
                                                    :site_id => @site.id
  end
  
  test "#restore should restore DeletedNewsletter back to Newsletter" do
    Newsletter.find_by_id(@deleted_newsletter.id).should == nil
    DeletedNewsletter.find_by_id(@deleted_newsletter.id).should_not == nil
    @deleted_newsletter.restore
    Newsletter.find_by_id(@deleted_newsletter.id).should_not == nil
    DeletedNewsletter.find_by_id(@deleted_newsletter.id).should == nil
  end
end
