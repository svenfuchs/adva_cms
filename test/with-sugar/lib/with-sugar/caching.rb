module With
  class Context
    def it_caches_the_page(options = {})
      before { with_perform_caching  }
      after  { reset_perform_caching }
      
      assertion "it caches the page" do
        message = "cache control should be public but isn't (#{@response.headers['Cache-Control']})"
        assert @response.headers['Cache-Control'].include?('public'), message
      end
    end
    
    def it_does_not_cache_the_page
      before { with_perform_caching  }
      after  { reset_perform_caching }
      
      assertion "it does not cache the page" do
        message = "cache control should be private but isn't (#{@response.headers['Cache-Control']})"
        assert @response.headers['Cache-Control'].include?('private'), message
      end
    end
  end
  
  protected
  
    def with_perform_caching
      @old_perform_caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
    end
    
    def reset_perform_caching
      ActionController::Base.perform_caching = @old_perform_caching
    end
end

