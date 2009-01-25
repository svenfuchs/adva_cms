class Test::Unit::TestCase
  def publish(article)
    article.update_attributes!(:published_at => Time.parse('2008-01-01 12:00:00')) unless article.published?
  end
  
  def unpublish(article)
    article.update_attributes!(:published_at => nil) if article.published?
  end
  
  def set_request_host!
    @request.host = @site.host if @request && @site
  end
  
  share :is_default_locale do
    before { I18n.default_locale = I18n.locale }
  end

  share :multi_sites_enabled do
    before { Site.multi_sites_enabled = true }
  end

  share :no_site do
    before do 
      Site.delete_all
    end
  end

  share :a_site do
    before do
      @site = Site.find_by_host 'site-with-sections.com'
      set_request_host!
    end
  end

  share :a_section do
    before do
      @section = Section.find_by_permalink 'a-section'
      @site = @section.site
      set_request_host!
    end
  end
  
  share :is_root_section do
    before do
      @section.reload.move_to_left_of(@section.site.sections.root) unless @section.root_section?
    end
  end
  
  share :comments_or_commenting_allowed do
    before do
      # no comments present but commenting is still allowed
      @site.comments.clear 
    end
  end
  
  share :comments_or_commenting_allowed do
    before do
      # commenting disallowed, but comments still present
      target = @articles || @article || @section
      Array(target).each { |t| t.update_attributes! :comment_age => -1 unless @article.comment_age == -1 }
    end
  end
  
  share :no_comments_and_commenting_not_allowed do
    before do
      @site.comments.clear
      target = @articles || @article || @section
      Array(target).each { |t| t.update_attributes! :comment_age => -1 unless @article.comment_age == -1 }
    end
  end
  
  share :a_category do
    before do
      @category = @section.categories.first
    end
  end

  # share :a_content do
  #   before do
  #     @content = @section.articles.first
  #   end
  # end

  share :an_article do
    before do
      @article = @section.articles.first
    end
  end

  share :a_published_article do
    before do
      @article = @section.articles.first
      publish @article
    end
  end

  share :an_unpublished_article do
    before do
      @article = @section.articles.first
      unpublish @article
    end
  end

  share :the_article_is_published do
    before do
      publish @article
    end
  end

  share :the_article_is_not_published do
    before do
      unpublish @article
    end
  end
  
  share :the_article_belongs_to_the_category do
    # nothing to do
  end

  share :the_article_does_not_belong_to_the_category do
    before do
      @article.categories.clear unless @article.categories.empty?
    end
  end
  
  share :article_has_an_excerpt do
    before { @article.update_attributes! :excerpt => 'the article excerpt' }
  end

  share :article_has_no_excerpt do
    # nothing to do
  end
  
  share :a_cached_page do
    before do 
      @cached_page = CachedPage.first
    end
  end
  
  share :a_plugin do
    before do
      @plugin = Engines.plugins[:test_plugin].clone
      @plugin.owner = @site
    end
  end

  share :a_theme do
    before do 
      @theme = @site.themes.build valid_theme_params
      @theme.save
    end
    
    after do
      FileUtils.unlink File.dirname(@theme.path.to_s) rescue Errno::ENOENT
    end
  end
  
  share :a_theme_template do
    before do
      @file = Theme::File.create(@theme, :localpath  => 'template.html.erb', :data => 'the template')
    end
  end

  share :valid_theme_params do
    before do
      @params = { :theme => valid_theme_params }
    end
  end
  
  share :invalid_theme_params do
    before do
      @params = { :theme => valid_theme_params.update(:name => '') }
    end
  end
  
  
  def valid_site_params
    { :site    => {:name => 'site name', :host => 'valid-host.com' },
      :section => {:type => 'Section', :title => 'section title'} }
  end
  
  def valid_install_params
    valid_site_params.merge :user => {:email => 'admin@admin.org', :password => 'password'}
  end
  
  def valid_section_params
    { :title      => 'the section title',
      :type       => 'Section' }
  end
  
  def valid_theme_params
    { :name      => 'Theme 1',
      :version    => '1.0.0', 
      :homepage   => 'http://homepage.org', 
      :author     => 'author', 
      :summary    => 'summary' }
  end

  def valid_article_params(user = nil)
    user ||= @user
    { :title      => 'an article',
      :body       => 'an article body',
      :author     => user.id }
  end
  
  def valid_category_params
    { :title      => 'the category title',
      :permalink  => 'the-category-title' }
  end
  

  share :valid_theme_template_params do
    before do
      @params = { :file => { :localpath  => 'template.html.erb', :data => 'the template' } }
    end
  end
  
  share :invalid_theme_template_params do
    before do
      @params = { :file => { :localpath  => 'invalid', :data => 'the template' } }
    end
  end

  share :valid_site_params do
    before do
      @params = valid_site_params
    end
  end
  
  share :invalid_site_params do
    before do
      @params = valid_site_params
      @params[:site][:name] = ''
    end
  end
  
  share :valid_section_params do
    before do
      @params = { :section => valid_section_params }
    end
  end
  
  share :invalid_section_params do
    before do
      @params = { :section => valid_section_params.update(:title => '') }
    end
  end
  
  share :valid_install_params do
    before do
      @params = valid_install_params
    end
  end
  
  share :invalid_install_params do
    before do
      @params = valid_install_params
      @params[:site][:name] = ''
    end
  end

  share :valid_article_params do
    before do
      @params = { :article => valid_article_params }
    end
  end

  [:title, :body].each do |attribute|
    share :invalid_article_params do
      before do
        @params = { :article => valid_article_params.update(attribute => '') }
      end
    end
  end
  
  share :valid_category_params do
    before do
      @params = { :category => valid_category_params }
    end
  end
  
  share :invalid_category_params do
    before do
      @params = { :category => valid_category_params.update(:title => '') }
    end
  end
  
  share :save_revision_param do
    before { @params.merge! :save_revision => '1' }
  end

  share :no_save_revision_param do
    before { @params = @params.except(:save_revision) }
  end
end