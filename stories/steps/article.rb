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
    raise "step expects @article_count to be set" unless @article_count
    (@article_count + 1).should == Article.count
  end

  Then "the article is deleted" do
    raise "step expects @article_count to be set" unless @article_count
    (@article_count - 1).should == Article.find(:all).size
  end
  
  # ADMIN VIEW

  When "the user visits the admin $section articles list page" do |section|
    raise "step expects the variable @blog or @section to be set" unless @blog or @section
    section = @blog || @section
    get admin_articles_path(section.site, section)
  end
  
  When "the user creates and publishes a new article" do
    lambda {
      When "the user visits the admin blog article creation page"
      When "the user fills in the admin article creation form with valid values"
      When "the user unchecks 'Yes, save this article as a draft'"
      When "the user clicks the 'Save article' button"
    }.should change(Article, :count).by(1)
  end

  When "the user fills in the admin article creation form with valid values" do
    fills_in 'title', :with => 'the article title'
    fills_in 'article[body]', :with =>'the article body'
    fills_in 'article[tag_list]', :with => '\"test article\"'
  end

  When "the user clicks on the article link" do
    raise "step expects the variable @article to be set" unless @article
    When "the user clicks on '#{@article.title}'"
  end

  When "the user visits the admin blog article creation page" do
    raise "step expects the variable @blog or @section to be set" unless @blog
    get new_admin_article_path(@blog.site, @blog)
    @article_count = 0
  end

  When "the user visits the admin $section article edit page" do |section|
    raise "step expects the variable @article and @blog or @section to be set" unless @article and (@blog or @section)
    section = @blog || @section
    get edit_admin_article_path(section.site, section, @article)
    @article_count = Article.count
  end

  Then "the page has an admin article creation form" do
    raise "step expects the variable @section or @blog to be set" unless @blog or @section
    section = @blog || @section
    action = admin_articles_path(section.site, section)
    response.should have_form_posting_to(action)
    @article_count = Article.count
  end

  Then "the page has an admin article editing form" do
    raise "step expects the variable @article and @blog or @section to be set" unless @article and (@blog or @section)
    section = @blog || @section
    action = admin_article_path(section.site, section, @article)
    response.should have_form_putting_to(action)
    @article_count = Article.count
  end

  Then "the page has a list of articles" do
    response.should have_tag('table#articles.list')
  end

  Then "the user is redirected to the admin blog articles page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles)
    response.should render_template("admin/blog/index")
  end
  
  Then "the user is redirected to the admin section articles page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles)
    response.should render_template("admin/articles/index")
  end

  Then "the user is redirected to the admin $section articles edit page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/articles/[\d]*/edit)
    response.should render_template('edit')
  end

  Then "the 'Save as draft?' checkbox is checked by default" do
    response.should have_tag("input#article-draft[type=?][value=?]", 'checkbox', 1)
  end
  
  # Then "the blog has sent pings" do    
  # end
  
  Then "the page displays the article" do
    raise "step expects the variable @article to be set" unless @article
    response.should have_tag("div#article_#{@article.id}.entry")
  end

  Then "the page displays the article as preview" do
    raise "step expects the variable @article to be set" unless @article
    response.should have_tag("div#article_#{@article.id}[class*=?]", 'entry')
  end

end
