scenario :comment_exists do
  @comment = Comment.new :author => stub_user, :commentable => stub_article, :body => 'body', :section => stub_section, :site => stub_site
  stub_methods @comment, :new_record? => false, :body_changed? => false

  stub_article.stub!(:[]).with('type').and_return 'Article' # TODO add #with to Stubby?
end

scenario :comment_created do
  stub_scenario :comment_exists
  stub_methods @comment, :new_record? => true
end

scenario :comment_updated do
  stub_scenario :comment_exists
  stub_methods @comment, :body_changed? => true
end

scenario :comment_approved do
  stub_scenario :comment_exists
  stub_methods @comment, :approved? => true
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_unapproved do
  stub_scenario :comment_exists
  stub_methods @comment, :approved? => false
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_destroyed do
  stub_scenario :comment_exists
  stub_methods @comment, :frozen? => true
end
