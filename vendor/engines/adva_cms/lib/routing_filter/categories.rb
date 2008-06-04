module RoutingFilter
  class Categories < Base
    def around_recognition(route, path, env, &block)
      unless path =~ %r(^/admin) # TODO ... should be defined through the dsl in routes.rb
        if match = path.match(%r(/categories/([^\./$]+)(?=/|\.|$)))
          # we do not scope category find here for simplicity, scoping
          # can (and should) easily be added at controller level
          if category = Category.find_by_path(match[1])
            path.sub! "/categories/#{category.path}", "/categories/#{category.id}"
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
