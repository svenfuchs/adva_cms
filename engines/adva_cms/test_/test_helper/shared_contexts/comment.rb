class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_comment_params
    { :body  => 'the comment body' }
  end

  share :valid_comment_params do
    before do
      @params = { :comment => { :commentable_id => @article.id, 
                                :commentable_type => 'Article', 
                                :body => 'the comment body' } }
    end
  end
  
  share :invalid_comment_params do
    before do
      @params = { :comment => { :commentable_id => @article.id, 
                                :commentable_type => 'Article', 
                                :body => nil } }
    end
  end

  share :an_approved_comment do
    before do 
      @comment = Comment.make :site => @site, 
                              :section => @section, 
                              :commentable => @article,
                              :author => User.make,
                              :approved => 1
    end
  end

  share :an_unapproved_comment do
    before do 
      @comment = Comment.make :site => @site, 
                              :section => @section, 
                              :commentable => @article,
                              :author => User.make,
                              :approved => 0
    end
  end
end