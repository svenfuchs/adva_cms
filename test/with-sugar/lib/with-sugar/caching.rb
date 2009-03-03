module With
  class Context
    def it_caches_the_page(options = {})
      before { with_page_caching  }
      after  { reset_page_caching }
      
      assertion "it caches the page" do
        path = ActionController::Base.send(:page_cache_path, @request.path)
        assert File.exists?(path), "expected #{path} to exist but doesn't"
      end
    end
    
    def it_does_not_cache_the_page
      before { with_page_caching  }
      after  { reset_page_caching }
      
      assertion "it caches the page" do
        path = ActionController::Base.send(:page_cache_path, @request.path)
        assert !File.exists?(path), "expected cached file #{path} not to exist but it does"
      end
    end
  end
  
  protected
  
    def with_page_caching
      @old_perform_caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
      clear_page_cache
    end
    
    def reset_page_caching
      ActionController::Base.perform_caching = @old_perform_caching
      clear_page_cache
    end

    def clear_page_cache
      cache_dir = @controller.send(:page_cache_directory)
      Pathname.new(cache_dir).rmtree if File.exists?(cache_dir)
    end
end

