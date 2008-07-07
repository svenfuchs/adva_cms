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

  When "the user visits the admin $section articles list page" do |section|
    raise "this step expects the variable @blog or @section to be set" unless @blog or @section
    object = (@blog or @section)
    get admin_articles_path(object.site, object)
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

  When "the user visits the admin $section article edit page" do |section|
    raise "this step expects the variable @article and @blog or @section to be set" unless @article and (@blog or @section)
    object = (@blog or @section)
    get edit_admin_article_path(object.site, object, @article)
    @article_count = Article.count
  end

  Then "the page has an admin article creation form" do
    raise "this step expects the variable @section or @blog to be set" unless @blog or @section
    object = (@blog or @section)
    action = admin_articles_path(object.site, object)
    response.should have_form_posting_to(action)
    @article_count = Article.count
  end

  Then "the page has an admin article editing form" do
    raise "this step expects the variable @article and @blog or @section to be set" unless @article and (@blog or @section)
    object = (@blog or @section)
    action = admin_article_path(object.site, object, @article)
    response.should have_form_putting_to(action)
    @article_count = Article.count
  end

  Then "the page has a list of articles" do
    response.should have_tag('table#articles.list')
  end

  Then "the user is redirected to the admin blog articles page" do |section|
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
  
  # TODO sections seems to have other problems too, because newly created section
  # from website leads to home and not to correct section.
  #Then "the page displays the article" do
  #  raise "this step expects the variable @article to be set" unless @article
  #  response.should have_tag("div#article_#{@article.id}.entry")
  #end

  # TODO Preview for section does not work.
  # Preview link from section articles leads to empty page.
  #Then "the page displays the article as preview" do
  #  raise "this step expects the variable @article to be set" unless @article
  #  response.should have_tag("div#article_#{@article.id}[class=?]", 'entry clearing')
  #end

end
