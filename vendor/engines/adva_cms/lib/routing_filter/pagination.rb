module RoutingFilter
  class Pagination < Base
    def around_recognition(route, path, env, &block)
      path.gsub! %r(/pages/([\d]+)/?$), ''
      returning yield(path, env) do |params|
        params[:page] = $1.to_i if $1
      end
    end
    
    # def before_generate(base, options)
    #   options.delete(:page)
    # end

    def after_generate(base, result, *args)
      # TODO Crap. Make this an around filter, too. Delete the :page option and
      # append it to the path accordingly. Not possible with separated before
      # and after filters.
      result.gsub! %r(\?page=([\d]+)$) do |page| "/pages/#{$1}" end
    end
  end
end