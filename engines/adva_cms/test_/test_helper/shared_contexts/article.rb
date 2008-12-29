class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_article_params(user)
    { :title      => 'an article',
      :body       => 'an article body',
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
  
  share :an_article do
    before do 
      @article = Article.make :site => @site, :section => @section
    end
  end
  
  share :the_article_is_published do
    before do 
      @article.update_attributes! :published_at => Time.parse('2000-01-01 12:00:00')
    end
  end

  share :a_published_article do
    before do 
      @article = Article.make :site => @site, :section => @section, :published_at => Time.parse('2000-01-01 12:00:00')
    end
  end
end