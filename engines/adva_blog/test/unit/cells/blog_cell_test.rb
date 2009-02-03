# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe BlogCell do
#   before :each do
#     CachedPage.delete_all
#     CachedPageReference.delete_all
#     Article.delete_all
# 
#     site = mock('site', :id => 1)
#     section = mock('section', :id => 1, :track_method_calls => nil) # TODO: use real object?
#     user = User.first || User.create!(:name => 'name', :email => 'email@email.org', :password => 'password')
# 
#     @article = Article.create!(:site => Site.first, :section => Section.first, :title => 'title', :body => 'body', :author => user)
# 
#     request = mock('request', :path => '/path/of/request')
#     @controller = mock('controller', :params => {}, :perform_caching => true, :request => request, :site => site, :section => section)
#     @cell = BlogCell.new(@controller, nil)
#   end
# 
#   it "it renders" do
#     @cell.render_state(:recent_articles).should =~ /recent \d* posts/i
#   end
# 
#   it "caches references for the assigned articles" do
#     @cell.render_state(:recent_articles)
#     reference = CachedPageReference.find_by_object_id_and_object_type(@article.id, 'Article')
#     reference.should be_instance_of(CachedPageReference)
#   end
# end
