module RoutingFilter
  class Categories < Base
    def around_recognition(route, path, env, &block)
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

    def after_generate(base, result, *args)
      return if result =~ %r(^/admin/)

      if match = result.match(%r(/categories/([\d]+)))
        category = Category.find match[1]
        result.sub! "/categories/#{match[1]}", "/categories/#{category.path}"
      end
    end
  end
end
