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
    Given "an article"
    Given "the article is published"
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

  When "the user clicks the link to article" do
    raise "this step expects the variable @article to be set" unless @article
    When "the user clicks on '#{@article.title}'"
  end
 
  Then "the page has a article creation form" do
    action = admin_articles_path(@blog.site, @blog)
    response.should have_form_posting_to(action)
    @article_count = Article.count
  end

  Then "the page has a article editing form" do
    raise "this step expects the variable @article to be set" unless @article
    raise "this step expects the variable @blog to be set" unless @blog
    action = "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/articles/#{@article.to_param}"
    response.should have_tag('form[action=?][method=?]', action, 'post')
    response.should have_tag('input[name=?][value=?]', '_method', 'put')
    @article_count = Article.find(:all).size
  end

  Then "the page has a list of articles" do
    response.should have_tag('table#articles.list')
  end

  Then "a new article is saved" do
    raise "Variable @article_count must be set before this step!" unless @article_count
    (@article_count + 1).should == Article.count
  end

  Then "the article is deleted" do
    raise "this step expects the variable @article_count to be set" unless @article
    (@article_count - 1).should == Article.find(:all).size
  end

  Then "the user is rendered to the blog's articles edit page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles/[\d]*/edit)
    response.should render_template('edit')
  end

  Then "the user is redirected to the blog's articles page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles)
    response.should render_template('admin/blog/index')
  end
end
