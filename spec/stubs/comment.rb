define Comment do
  belongs_to :author, stub_user
  
  methods  :id => 1,
           :body => 'body', 
           :body_html => 'body html',
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :created_at => Time.now,
           :approved? => true,
           :update_attributes => true,
           :save => true,
           :destroy => true,
           :has_attribute? => true

  instance :comment
end

scenario :comment do
  @comment = stub_comment
  @comments = stub_comments
  @comment.stub!(:commentable).and_return @article || @wikipage
end

scenario :comment_exists do
  scenario :site, :section, :article, :user
  @comment = Comment.new :author => stub_user, :commentable => stub_article, :body => 'body'
  stub_methods @comment, :new_record? => false, :body_changed? => false
end

scenario :comment_created do
  scenario :comment_exists
  stub_methods @comment, :new_record? => true
end

scenario :comment_updated do
  scenario :comment_exists
  stub_methods @comment, :body_changed? => true
end

scenario :comment_approved do
  scenario :comment_exists
  stub_methods @comment, :approved? => true
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_unapproved do
  scenario :comment_exists
  stub_methods @comment, :approved? => false
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_destroyed do
  scenario :comment_exists
  stub_methods @comment, :frozen? => true
end
