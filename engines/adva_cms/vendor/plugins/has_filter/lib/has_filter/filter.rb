require_dependency 'has_filter/filter/base'
require_dependency 'has_filter/filter/categorized'
require_dependency 'has_filter/filter/chain'
require_dependency 'has_filter/filter/set'
require_dependency 'has_filter/filter/state'
require_dependency 'has_filter/filter/tagged'
require_dependency 'has_filter/filter/text'

module HasFilter
  module Filter
		class << self
		  def build(type, *args)
	      HasFilter::Filter.const_get(type.to_s.classify).build(*args)
	    end
	  end
	end
end