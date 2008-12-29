class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_category_params
    { :title      => 'the category title',
      :permalink  => 'the-category-title' }
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

  share :a_category do
    before do 
      @category = Category.make :section => @section
    end
  end
end