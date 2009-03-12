require File.dirname(__FILE__) + '/../test_helper.rb'

class UrlHistoryEntryTest < ActiveSupport::TestCase
  include UrlHistory
  
  test "updates the date and permalink values 
        if the resource responds to :full_permalink and the params have a :year key" do
    article = Blog.first.articles.first
    entry = Entry.new :url => 'url', :resource => article, :params => {}
    assert article.full_permalink, entry.updated_params
  end
  
  test "updates the permalink value 
        if the resource responds to :permalink" do
    article = Page.first.articles.first
    entry = Entry.new :url => 'url', :resource => article, :params => {}
    assert({ :permalink => article.permalink }, entry.updated_params)
  end
end
