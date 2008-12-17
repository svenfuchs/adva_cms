class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_article_params(user)
    { :title      => 'the article title',
      :body       => 'the article body',
      :author     => user.id }
  end

  share :valid_article_params do
    before do
      @params = { :article => valid_article_params(User.make) }
    end
  end
  
  # FIXME: controller breaks when :author is missing
  [:title, :body].each do |attribute|
    share :invalid_article_params do
      before do
        @params = { :article => valid_article_params(User.make).update(attribute => '') }
      end
    end
  end

  share :a_published_article do
    before do 
      @article = Article.make :site => @site, :section => @section, :published_at => Time.now
    end
  end
end