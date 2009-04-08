module Menus
	class Item
	  attr_reader :id, :url, :options
	  
		def initialize(id, options = {})
		  @id = id
		  @options = options
		  @caption = options.delete(:caption)
		  @tag = options.delete(:tag)
		  @url = options.delete(:url)
	  end
    
    def caption
      @caption ||= id.is_a?(Symbol) ? I18n.t(id, :scope => :'adva.titles') : id
    end
	  
	  def tag
	    @tag ||= url ? Tags::A.new(caption, :href => url) : Tags::Span.new(caption)
    end

		def render(scope)
			Tags::Li.new(tag.render, options).render
		end
    
    def activate(path)
      add_class_name('active') if path && path.starts_with?(url)
    end
  
    def add_class_name(class_name)
      options[:class] ||= ''
      options[:class] = options[:class].to_s.split(' ').push(class_name).uniq.join(' ')
    end
	end
end