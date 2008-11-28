module RoutingFilter
  class Categories < Base
    def around_recognize(path, env, &block)
      unless path =~ %r(^/admin) # TODO ... should be defined through the dsl in routes.rb
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        if match = path.match(%r(/(?:#{types})/([\d]+)/categories/([^\./$]+)(?=/|\.|$)))
          if section = Section.find(match[1])
            if category = section.categories.find_by_path(match[2])
              path.sub! "/categories/#{category.path}", "/categories/#{category.id}"
            end
          end
        end
      end
      yield path, env
    end

    def around_generate(*args, &block)
      returning yield do |result|
        if result !~ %r(^/admin/) and result =~ %r(/categories/([\d]+))
          category = Category.find $1
          result.sub! "/categories/#{$1}", "/categories/#{category.path}"
        end
      end
    end
  end
end
