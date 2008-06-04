define Category do
  belongs_to :section
  has_many :children, stub_categories(:child)
  
  methods  :valid? => true, 
           :save => true, 
           :update_attributes => true, 
           :destroy => true,
           :has_attribute? => true
           
  instance :category,
           :id => 1,
           :title => 'Foo', 
           :path => 'foo'
          
  instance :child,
           :id => 2, 
           :title => 'Bar', 
           :path => 'bar',
           :children => []

end

scenario :category do 
  @category = stub_category(:category)
  @categories = stub_categories
  
  @category.stub!(:contents).and_return(@articles || @wikipages)

  Category.stub!(:new).and_return @category
  Category.stub!(:find).and_return @category
  Category.stub!(:find_by_path).and_return @category
end
