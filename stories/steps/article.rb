factories :articles

steps_for :article do
  Given "an article" do
    @article = create_article
  end
  
  Given "an article that has $options" do |options|
    @article = create_article options
  end
  
  Given "the article is published" do
    @article.update_attributes! :published_at => '2008-01-01 12:00:00'
  end
  
  Given "the article is not published" do
    @article.update_attributes! :published_at => nil
  end
  
  Given "the article does not allow commenting" do
    @article.update_attributes! :comment_age => -1
  end
  
  Given "a published article" do
    $rspec_story_steps[:article].find(:given, "an article").perform(self)
    $rspec_story_steps[:article].find(:given, "the article is published").perform(self)
  end
  
  Given "an unrelated category" do
    @another_category = create_category :title => 'an unrelated category'
  end
  
  Given "an unrelated tag" do
    @another_tag = create_tag :name => 'baz'
  end
  
  Given "the article has a comment" do
    @approved_comment = create_comment :commentable => @article
  end
  
  Given "the comment is approved" do
    @approved_comment.update_attributes! :approved => true
  end

  When "the user fills in the article creation form with valid values" do
    fills_in 'title', :with => 'the article title'
    fills_in 'article[body]', :with =>'the article body'
    fills_in 'article[tag_list]', :with => '\"test article\"'
  end
 
  Then "the page has a article creation form" do
    action = "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/articles"
    response.should have_tag('form[action=?][method=?]', action, 'post')
    @article_count = Article.find(:all).size
  end

  Then "a new article is saved" do
    raise "Variable @article_count must be set before this step!" unless @article_count
    (@article_count + 1).should == Article.find(:all).size
  end

  Then "the user is rendered to the blog's articles edit page" do
    response.should render_template('edit')
  end
end
