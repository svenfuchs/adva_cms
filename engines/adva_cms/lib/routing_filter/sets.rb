module RoutingFilter
  class Sets < Base
    def around_recognize(path, env, &block)
      unless path =~ %r(^/([\w]{2,4}/)?admin) # TODO ... should be defined through the dsl in routes.rb
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        match = match_path(path, types)
        if match
          if section = Section.find(match[1])
            if set = section.sets.find_by_path(match[2])
              path.sub! "/sets/#{set.path}", "/sets/#{set.id}"
            end
          end
        end
      end
      yield path, env
    end
    
    def match_path(path, types)
      # all 4 digit child sets will die
      #   sets/1234 => 1234 but sets/1234/1234 => 1234
      # this because we want to display set contents per year like sets/set/2009
      #
      # all combinations of 4 and 2 digit child sets will die also (after the root level)
      #   sets/1234/45 => 1234/45 but sets/1234/1234/12 => 1234
      # this because we want to display set contents per year and month like sets/set/2009/12
      
      unless path.match(%r(sets/\d{4}$))
        year = path.match(%r(/\d{4}$))
        path = path.sub(year[0], '') if year
      end
      
      unless path.match(%r(sets/\d{4}/\d{2}$))
        year_and_month = path.match(%r(/\d{4}/\d{2}$|/\d{4}/\d{1}$))
        path = path.sub(year_and_month[0], '') if year_and_month
      end
      
      path.match(%r(/(?:#{types})/([\d]+)/sets/([^\.$]+)(?=/|\.|$)))
    end
    
    def around_generate(*args, &block)
      returning yield do |result|
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/([\w]{2,4}/)?admin/) and result =~ %r(/sets/([\d]+))
          set = Category.find $1
          result.sub! "/sets/#{$1}", "/sets/#{set.path}"
        end
      end
    end
  end
end
