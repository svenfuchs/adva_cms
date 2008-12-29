class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_wikipage_params(user)
    { :title      => 'a wikipage',
      :body       => 'a wikipage body',
      :author     => user.id }
  end

  share :valid_wikipage_params do
    before do
      @params = { :wikipage => valid_wikipage_params(User.make) }
    end
  end
  
  share :invalid_wikipage_params do
    before do
      @params = { :wikipage => valid_wikipage_params(User.make).update(:title => '') }
    end
  end
  
  share :a_wikipage do
    before do 
      @wikipage = Wikipage.make :site => @site, :section => @section, :tag_list => 'foo bar'
    end
  end
  
  share :a_wikipage_category do
    before do
      @category = Category.make :section => @section
      @wikipage.categories << @category
    end
  end
  
  share :no_wikipage_category do
    # nothing to do, just a placeholder
  end
end