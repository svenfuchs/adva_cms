define Article do
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments
  has_many :categories
  has_many :tags
  has_one  :comments_counter, stub_counter
  
  belongs_to :site
  belongs_to :section
  belongs_to :author, stub_user

  methods  :id => 1,
           :type => 'Article',
           :title => 'An article',
           :permalink => 'an-article',
           :full_permalink => {:year => 2008, :month => 1, :day => 1, :permalink => 'an-article'},
           :excerpt => 'excerpt',
           :excerpt_html => 'excerpt html',
           :body => 'body',
           :body_html => 'body html',
           :tag_list => 'foo bar',
           :version => 1,
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :comment_filter => 'textile-filter',
           :comment_age => 0,
           :primary? => false,
           :accept_comments? => true,
           :has_excerpt? => true,
           :published_at => Time.now,
           :published? => true,
           :published_at? => true,
           :filter => nil,
           :attributes= => nil,
           :save => true, 
           :save_without_revision => true, 
           :update_attributes => true, 
           :has_attribute? => true,
           :destroy => true,
           :save_version_on_create => nil,
           :increment_counter => nil,
           :decrement_counter => nil

  instance :article           
end
  
scenario :article do 
  @article = stub_article
  @articles = stub_articles
  
  @article.stub!(:[]).with('type').and_return 'Article'
  Article.stub!(:find).and_return @article
end

scenario :blank_article do
  scenario :site, :section, :user
  Article.delete_all
  @article = Article.new :author => stub_user, 
                         :site_id => stub_site, :section_id => stub_section, 
                         :title => 'An article', 
                         :body => 'body'
end

scenario :article_exists do
  scenario :blank_article
  stub_methods @article, :new_record? => false, :save_version? => false
end

scenario :article_created do
  scenario :article_exists
  @article.id = nil                       
  stub_methods @article, :new_record? => true
end

scenario :article_revised do
  scenario :article_exists
  stub_methods @article, :save_version? => true
end

scenario :article_published do
  scenario :article_exists
  stub_methods @article, :published? => true
  stub_methods @article, :published_at_changed? => true
end

scenario :article_unpublished do
  scenario :article_exists
  stub_methods @article, :published? => false
  stub_methods @article, :published_at_changed? => true
end

scenario :article_destroyed do
  scenario :article_exists
  stub_methods @article, :frozen? => true
end

scenario :article_published_on_2008_1_1 do
  scenario :blank_article
  Article.delete_all
  @article.published_at = Time.zone.local 2008, 1, 1
  @article.save!
end

scenario :six_articles_published_in_three_months do
  scenario :user
  Article.delete_all
  
  @site = Site.create! :host => 'host', :name => 'site', :title => 'title'
  @blog = Blog.create! :title => 'title', :site => @site
  
  1.upto(3) do |month|
    1.upto(month) do |day|
      Article.create :author => stub_user, :site => @site, :section => @blog, 
                     :title => "Article on day #{day} in month #{month}", :body => 'body',
                     :published_at => Time.zone.local(2008, month, day)
    end
  end
end

