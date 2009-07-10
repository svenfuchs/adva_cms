module RoutingFilter
  class Categories < Base
    def around_recognize(path, env, &block)
      unless path =~ %r(^/([\w]{2,4}/)?admin) # TODO ... should be defined through the dsl in routes.rb
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        match = match_path(path, types)
        if match
          if section = Section.find(match[1])
            if category = section.categories.find_by_path(match[2])
              path.sub! "/categories/#{category.path}", "/categories/#{category.id}"
            end
          end
        end
      end
      yield path, env
    end
    
    def match_path(path, types)
      # all 4 digit child categories will die
      #   categories/1234 => 1234 but categories/1234/1234 => 1234
      # this because we want to display category contents per year like categories/category/2009
      #
      # all combinations of 4 and 2 digit child categories will die also (after the root level)
      #   categories/1234/45 => 1234/45 but categories/1234/1234/12 => 1234
      # this because we want to display category contents per year and month like categories/category/2009/12
      
      unless path.match(%r(categories/\d{4}$))
        year = path.match(%r(/\d{4}$))
        path = path.sub(year[0], '') if year
      end
      
      unless path.match(%r(categories/\d{4}/\d{2}$))
        year_and_month = path.match(%r(/\d{4}/\d{2}$|/\d{4}/\d{1}$))
        path = path.sub(year_and_month[0], '') if year_and_month
      end
      
      path.match(%r(/(?:#{types})/([\d]+)/categories/([^\.$]+)(?=/|\.|$)))
    end

    def around_generate(*args, &block)
      returning yield do |result|
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/([\w]{2,4}/)?admin) and result =~ %r(/categories/([\d]+))
          category = Category.find $1
          result.sub! "/categories/#{$1}", "/categories/#{category.path}"
        end
      end
    end
  end
end
