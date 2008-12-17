class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_article_params(user)
    { :title      => 'the article title',
      :body       => 'the article body',
      :author     => user.id }
  end

  share :valid_article_params do
    before do
      @params = { :article => valid_article_params(@user) }
    end
  end
  
  # FIXME: controller breaks when :author is missing
  [:title, :body].each do |missing|
    share :invalid_article_params do
      before do
        @params = { :article => valid_article_params(@user).except(missing) }
      end
    end
  end
end