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
  
  def default_routing_filters
    %w(locale categories sets section_root section_paths pagination).inject(RoutingFilter::Chain.new) do |filters, name|
      klass = RoutingFilter.const_get(name.camelize)
      filters << klass.new({})
    end
  end

  share :default_routing_filters do
    before do
      names = RoutingFilter.constants - %w(Chain Base)
      klasses = names.map { |name| RoutingFilter.const_get(name) }
      @current_states = klasses.inject({}) { |states, klass| states[klass] = klass.active; states }
      
      default_filters = %w(Locale Categories Sets SectionRoot SectionPaths Pagination)
      klasses.each { |klass| klass.active = default_filters.include?(klass.name.gsub('RoutingFilter::', '')) }
    end
    
    after do
      @current_states.each { |klass, state| klass.active = state }
    end
  end

  share :is_default_locale do
    before { I18n.default_locale = I18n.locale }
  end
  
  share :rescue_action_in_public do
    before { rescue_action_in_public! }
  end

  share_condition :default_theme do
    assigns(:site).themes.active.empty?
  end

  # FIXME abstract these
  share :multi_sites_enabled do
    before do
      @old_multi_sites_enabled = Site.multi_sites_enabled
      Site.multi_sites_enabled = true
    end
    after do
      Site.multi_sites_enabled = @old_multi_sites_enabled
    end
  end

  share :single_site_enabled do
    before do
      @old_multi_sites_enabled = Site.multi_sites_enabled
      Site.multi_sites_enabled = false
    end
    after do
      Site.multi_sites_enabled = @old_multi_sites_enabled
    end
  end

  share :perform_caching_enabled do
    before do
      @old_perform_caching_enabled = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = true
    end
    after do
      ActionController::Base.perform_caching = @old_perform_caching_enabled
    end
  end

  share :perform_caching_disabled do
    before do
      @old_perform_caching_enabled = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = false
    end
    after do
      ActionController::Base.perform_caching = @old_perform_caching_enabled
    end
  end

  share :access_granted do
    before do
      stub(@controller).require_authentication
      stub(@controller).guard_permission
      stub(@controller).has_permission? { true }
    end
  end

  [:superuser, :admin, :moderator, :user, :anonymous].each do |role|
    share :"is_#{role}" do
      before("log in as #{role}") do
        article = role.to_s[0, 1].downcase == 'a' ? 'an' : 'a'
        name = "#{article} #{role}"
        @user = User.find_by_first_name(name) or raise "could not find user named \"#{name}\""
        login @user
      end
    end
  end

  share :no_user do
    before do
      User.delete_all
    end
  end

  share :no_site do
    before do
      Site.delete_all
    end
  end

  share :a_site do
    before do
      @site = Site.find_by_host 'site-with-pages.com'
      set_request_host!
    end
  end

  share :a_page do
    before do
      @section = Section.find_by_permalink 'a-page'
      @site = @section.site
      set_request_host!
    end
  end

  share :an_unpublished_section do
    before do
      @section = Section.find_by_permalink('an-unpublished-section')
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
      @article = @section.articles.first # .find_by_title 'a page article'
      publish @article
    end
  end

  share :a_published_photo do
    before do
      @photo = @album.photos.first
      publish @photo
    end
  end

  share :an_unpublished_article do
    before do
      @article = @section.articles.first
      unpublish @article
    end
  end

  share :an_unpublished_photo do
    before do
      @photo = @album.photos.first
      unpublish @photo
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
      @article.categories.clear if @article.categories.present?
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
      @plugin = @site.plugins[:test_plugin].clone
    end
  end


  def valid_site_params
    { :site    => { :name => 'site name', :host => 'valid-host.com' },
      :section => { :type => 'Page', :title => 'page title' } }
  end

  def valid_install_params
    valid_site_params.merge :user => { :email => 'admin@admin.org', :password => 'password' }
  end

  def valid_page_params
    { :title      => 'the page title',
      :type       => 'Page' }
  end

  def valid_article_params(user = nil)
    user ||= @user
    { :title     => 'an article',
      :body      => 'an article body',
      :author_id => user.id }
  end

  def valid_category_params
    { :title     => 'the category title',
      :permalink => 'the-category-title' }
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

  share :valid_page_params do
    before do
      @params = { :section => valid_page_params }
    end
  end

  share :invalid_page_params do
    before do
      @params = { :section => valid_page_params.update(:title => '') }
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

  share :fixed_time do
    before do
      Time.stubs(:now).returns Time.utc(2009,2,3, 15,00,00)
      Date.stubs(:today).returns Date.civil(2009,2,3)
    end
  end
end