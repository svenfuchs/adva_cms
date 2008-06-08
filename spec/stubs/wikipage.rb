define Wikipage do
  belongs_to :site
  belongs_to :section, stub_wiki
  belongs_to :author, stub_user

  has_many :versions, [stub_wikipage(:rev1), stub_wikipage(:rev4)], :size => 4
  has_many :categories, stub_categories
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments

  methods  :id => 1,
           :type => 'Wikipage',
           :title => 'A wikipage',
           :permalink => 'a-wikipage', 
           :body => 'body',
           :body_html => 'body html',
           :tag_list => 'foo bar',
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :comment_filter => 'textile-filter',
           :comment_age => 0,
           :accept_comments? => true,
           :updated_at => Time.now,
           :home? => false,
           :valid? => true,
           :save => true,
           :update_attributes => true,
           :destroy => true,
           :revert_to => stub_wikipage,
           :diff_against_version => 'the diff',
           :save_version_on_create => nil,
           :user= => nil,
           :has_attribute? => true
 
  instance :wikipage,
           :version => 4

  instance :rev1,
           :version => 1
     
  instance :rev4,
           :version => 4
           
end

scenario :wikipage do
  @wikipage = stub_wikipage
  @wikipages = stub_wikipages
  @wikipages.stub!(:total_entries).and_return 2
end

scenario :wikipage_exists do
  scenario :site, :section, :user
  @wikipage = Wikipage.new :author => stub_user, :site_id => 1, :section_id => 1, :title => 'title', :body => 'body'
  stub_methods @wikipage, :new_record? => false, :save_version? => false
end

scenario :wikipage_created do
  scenario :wikipage_exists
  stub_methods @wikipage, :new_record? => true
end

scenario :wikipage_revised do
  scenario :wikipage_exists
  stub_methods @wikipage, :save_version? => true
end

scenario :wikipage_destroyed do
  scenario :wikipage_exists
  stub_methods @wikipage, :frozen? => true
end

