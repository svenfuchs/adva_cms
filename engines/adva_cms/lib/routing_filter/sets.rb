module RoutingFilter
  class Sets < Base
    def around_recognize(path, env, &block)
      unless path =~ %r(^/admin) # TODO ... should be defined through the dsl in routes.rb
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        if match = path.match(%r(/(?:#{types})/([\d]+)/sets/([^\./$]+)(?=/|\.|$)))
          if section = Section.find(match[1])
            if set = section.sets.find_by_path(match[2])
              path.sub! "/sets/#{set.path}", "/sets/#{set.id}"
            end
          end
        end
      end
      yield path, env
    end

    def around_generate(*args, &block)
      returning yield do |result|
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/admin/) and result =~ %r(/sets/([\d]+))
          set = Category.find $1
          result.sub! "/sets/#{$1}", "/sets/#{set.path}"
        end
      end
    end
  end
end