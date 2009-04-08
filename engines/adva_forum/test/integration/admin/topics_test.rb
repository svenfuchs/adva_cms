require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class TopicsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  test 'an admin visits the topics index on backend' do
    login_as_admin
    visit_topic_index
  end

  def visit_topic_index
    @forum = Forum.find_by_permalink('a-forum-without-boards')

    get admin_topics_path(@site, @forum)
    assert_template 'admin/topics/index'
  end
end