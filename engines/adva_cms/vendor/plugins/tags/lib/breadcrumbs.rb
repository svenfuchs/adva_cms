class Breadcrumbs < Tags::Tag
  self.tag_name = :ul
  
  def initialize(items)
    super :id => 'breadcrumbs'
    @items = items
  end

  def content
    @items[0, @items.size - 1].map { |item| Tags::Li.new(item.content).render }.join + 
    Tags::Li.new(@items.last.text, :class => 'last').render
  end
end