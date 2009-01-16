define Category do
  belongs_to :section
  has_many :children, stub_categories(:child)

  methods  :valid? => true,
           :save => true,
           :update_attributes => true,
           :destroy => true,
           :has_attribute? => true,
           :track_method_calls => nil

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
