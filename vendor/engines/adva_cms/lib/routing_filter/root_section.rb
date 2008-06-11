module RoutingFilter
  class RootSection < Base
    # this pattern matches a path that starts (aside from an optional locale) 
    # with a single slash or one of articles|pages|categories|tags, 4 digits 
    # or a dot followed by anything. 
    # 
    # So all of the following paths will match:
    # / and /de 
    # /articles and /de/articles (same with pages, categories, tags)
    # /2008 and /de/2008
    # /.rss and /de.rss
    
    # TODO ... should be defined through the dsl in routes.rb
    @@pattern = %r(^/?(/[\w]{2})?(/articles|/pages|/categories|/tags|/\d{4}|\.|/?$))

    # prepends the root section path to the path if the given pattern matches          
    def around_recognition(route, path, env, &block)
      if match = path.match(@@pattern) and site = Site.find_by_host(env[:host_with_port])
        section = site.sections.root
        path.sub! /^#{match[0]}/, "#{match[1]}/#{section.type.pluralize.downcase}/#{section.id}#{match[2]}"
      end
      yield path, env
    end

    def after_generate(base, result, *args)
      if site = base.instance_variable_get(:@site) and root = site.sections.root     
        # TODO are after filters applied in a reverse order or what?     
        pattern = %r(^(/[\w]{2})?(/(?:#{root.type.pluralize.downcase}|sections)/#{root.id}(\.|/|$)))
        # pattern = %r(^(/[\w]{2})?(/#{root.path}(\.|/|$)))
        if match = result.match(pattern)
          result.sub! match[2], match[3] unless match[3] == '.'
          result.replace '/' if result.empty?
        end
      end
    end          
  end
end
