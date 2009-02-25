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
        target = Array(result).first
        # append the extension to the path unless it has a known extension
        unless target =~ %r(^/admin) or target.blank? or target == '/'
          extensions = Mime::EXTENSION_LOOKUP.keys
          target.replace(target.sub(/(\?|$)/, '.html\1')) unless target =~ /\.#{extensions.join('|')}(\?|$)/
        end
      end
    end
  end
end