define Tag do
  instance :tag_foo,
           :id => 1, 
           :name => 'foo'

  instance :tag_bar,
           :id => 2, 
           :name => 'bar'
end

scenario :tag do 
  @tag = stub_tag(:tag_foo)
  Tag.stub!(:find).and_return stub_tags(:all)
end
