define Wiki do
  belongs_to :site

  has_many :wikipages,  [:find, :find_by_permalink, :find_or_initialize_by_permalink, :build, :create] => stub_wikipage, 
                         :paginate => stub_wikipages
                     
  has_many :categories, [:find, :build, :root] => stub_category, [:paginate, :roots] => stub_categories
        
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments

  methods  :render_options => {},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :accept_comments? => true,
           :valid? => true,
           :root_section? => true,
           :tag_counts => [],
           :has_attribute? => true,
           :required_roles => { :manage_wikipages => :admin, :manage_categories => :admin },
           :required_role_for => :admin

  instance :wiki,
           :id => 1,
           :type => 'Wiki', 
           :path => 'wiki',
           :title => 'wiki title'

end

scenario :wiki do 
  @wiki = stub_wiki
  
  Section.stub!(:find).and_return @wiki
  Section.stub!(:types).and_return ['Section', 'Blog', 'Wiki']
  Section.stub!(:paths).and_return ['section', 'sections/section', 'blog', 'blogs/blog', 'wikis/wiki', 'wiki']
  
  # @site.stub_collection! :sections, @sections, [:find, :build, :root] => @wiki if @site
end
