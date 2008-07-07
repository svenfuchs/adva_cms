factories :sections, :articles

steps_for :article do
  Given 'the article does not allow commenting' do
    @article.update_attributes! :comment_age => -1
  end
  
  Given "the article has no comments" do
    @article.comments.clear
  end
  
  Given "the article has a comment" do
    @comment = create_comment :commentable => @article
  end
  
  Given "the article has an approved comment" do
    Given "the article has a comment"
    @comment.update_attributes! :approved => true
  end
  
  Given "the article has an unapproved comment" do
    Given "the article has a comment"
  end
  
  Then "the article has an unapproved comment" do
    @article.unapproved_comments.count.should == 1
    @comment = @article.unapproved_comments.first
  end

  Then "a new article is saved" do
    raise "this step expects @article_count to be set" unless @article_count
    (@article_count + 1).should == Article.count
  end

  Then "the article is deleted" do
    raise "this step expects @article_count to be set" unless @article_count
    (@article_count - 1).should == Article.find(:all).size
  end
  
  # ADMIN VIEW

  When "the user visits the admin blog articles list page" do
    get admin_articles_path(@blog.site, @blog)
  end

  When "the user fills in the admin article creation form with valid values" do
    fills_in 'title', :with => 'the article title'
    fills_in 'article[body]', :with =>'the article body'
    fills_in 'article[tag_list]', :with => '\"test article\"'
  end

  When "the user clicks on the article link" do
    raise "this step expects the variable @article to be set" unless @article
    When "the user clicks on '#{@article.title}'"
  end

  When "the user visits the admin blog article edit page" do
    When "the user visits the admin blog articles list page"
    Then "the page has a list of articles"
    When "the user clicks on the article link"
    Then "the page has a admin article editing form"
  end

  Then "the page has an admin article creation form" do
    action = admin_articles_path(@blog.site, @blog)
    response.should have_form_posting_to(action)
    @article_count = Article.count
  end

  Then "the page has a admin article editing form" do
    raise "this step expects the variable @article to be set" unless @article
    raise "this step expects the variable @blog to be set" unless @blog
    action = admin_article_path(@blog.site, @blog, @article)
    response.should have_form_putting_to(action)
    @article_count = Article.count
  end

  Then "the page has a list of articles" do
    response.should have_tag('table#articles.list')
  end

  Then "the user is redirected to the admin blog articles list page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles)
    response.should render_template('admin/blog/index')
  end
  
  Then "the user is redirected to the admin blog article's edit page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles/[\d]*/edit)
    response.should render_template('edit')
  end

  Then "the 'Save as draft?' checkbox is checked by default" do
    response.should have_tag("input#article-draft[type=?][value=?]", 'checkbox', 1)
  end

  Then "the page displays the article" do
    raise "this step expects the variable @article to be set" unless @article
    response.should have_tag("div#article_#{@article.id}.entry")
  end

  Then "the page displays the article as preview" do
    raise "this step expects the variable @article to be set" unless @article
    response.should have_tag("div#article_#{@article.id}[class=?]", 'entry clearing')
  end

end
