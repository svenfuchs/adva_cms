module RoutingFilter
  class Sections < Base
    def around_recognition(route, path, env, &block)
      unless path =~ %r(^/admin) # TODO ... should be defined through the dsl in routes.rb
        # sort section paths by length, longest first
        @site = Site.find_by_host env[:host_with_port]
        paths = @site.sections.paths.sort{|a, b| b.size <=> a.size }.join('|')

        # if the path is, aside from a slash and an optional locale, the 
        # leftmost part of the path, replace it by "sections/:id" segments
        if !paths.empty? and match = path.match(%r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)))
          if section = @site.sections.detect{|section| section.path == match[2] }
            path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/#{match[1]}#{section.type.pluralize.downcase}/#{section.id}#{match[3]}"
            # path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/sections/#{section.id}#{match[3]}"
          end
        end
      end
      yield path, env
    end
    
    def after_generate(base, result, *args)
      return if result =~ %r(^/admin/)
      
      types = Section.types.map{|type| type.downcase.pluralize }.join('|')
      if match = result.match(%r((#{types})/([\d]+(/?))(\.?))) # ?(?=\b)?
        section = Section.find match[2].to_i
        result.sub! "#{match[1]}/#{match[2]}", "#{section.path}#{match[3]}"
      end
    end          
  end
end