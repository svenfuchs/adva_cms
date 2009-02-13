require 'routing_filter/base'

module RoutingFilter
  class ForceHtml < Base
    def around_recognize(path, env, &block)
      # remove the extension from the path
      path.gsub! /\.html$/, '' unless path =~ %r(^/admin)
      yield(path, env)
    end

    def around_generate(*args, &block)
      returning yield do |result|
        # append the extension to the path unless it has a known extension
        unless result =~ %r(^/admin) or result.blank? or result == '/'
          extensions = Mime::EXTENSION_LOOKUP.keys
          result.replace(result.sub(/(\?|$)/, '.html\1')) unless result =~ /\.#{extensions.join('|')}(\?|$)/
        end
      end
    end
  end
end