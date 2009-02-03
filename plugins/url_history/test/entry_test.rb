require File.dirname(__FILE__) + '/test_helper.rb'

class UrlHistoryEntryTest < ActiveSupport::TestCase
  include UrlHistory
  
  def setup
    super
    @article = Article.new :permalink => 'the-permalink'
    @entry = Entry.new :url => 'url', :resource => @article, :params => {}
  end
  
  test "updates the date and permalink values 
        if the resource responds to :full_permalink and the params have a :year key" do
    assert @article.full_permalink, @entry.updated_params
  end
  
  test "updates the permalink value 
        if the resource responds to :permalink" do
    assert({ :permalink => @article.permalink }, @entry.updated_params)
  end
end
