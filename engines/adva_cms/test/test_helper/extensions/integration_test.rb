module ActionController
  class IntegrationTest
    def default_theme?
      controller.site.themes.active.empty?
    end

    def displays_article(article)
      has_tag '.entry', :text => /#{article.title}/
    end

    def does_not_display_article(article)
      has_tag '.entry', :text => /#{article.title}/, :count => 0
    end

    def displays_comments(comments)
      comments.each do |comment|
        has_tag ".comment", :text => /#{comment.body}/
      end
    end

    def renders_template(template)
      assert_template template
      assert_response :success
    end

    # Testing cookie based flash message.
    #
    # Example usage:
    #   renders_flash 'It was successfully updated!'
    #
    def renders_flash(message)
      regexp = Regexp.new(message.gsub(' ', '\\\+'))
      assert cookies['flash'] =~ regexp,
        "Flash message does NOT MATCH: #{message}\n" +
        "  We got flash cookie: #{cookies['flash']}\n  what doesn't match to our test regexp: #{regexp}"
      cookies.delete :flash
    end
    alias :assert_flash :renders_flash

    def use_site!(site)
      site = Site.find_by_name(site) unless site.is_a?(Site)
      returning site do |site|
        @integration_session ||= open_session
        @integration_session.host! site.host
      end
    end

    def login_as_user
      raise "need to set the current site before loggin in" unless @integration_session
      post "/session", :user => {:email => 'a-user@example.com', :password => 'a password'}
      assert controller.authenticated?
      controller.current_user
    end

    def login_as_admin
      raise "need to set the current site before loggin in" unless @integration_session
      post "/session", :user => {:email => 'an-admin@example.com', :password => 'a password'}
      assert controller.authenticated?
      assert controller.current_user.has_role?(:admin, controller.site)
    end

    def login_as_designer
      raise "need to set the current site before loggin in" unless @integration_session
      post "/session", :user => {:email => 'a-designer@example.com', :password => 'a password'}
      assert controller.authenticated?
      puts controller.current_user.roles.inspect
      assert controller.current_user.has_role?(:designer, controller.site)
    end

    def login_as_superuser
      raise "need to set the current site before loggin in" unless @integration_session
      post "/session", :user => {:email => 'a-superuser@example.com', :password => 'a password'}
      assert controller.authenticated?
      assert controller.current_user.has_role?(:superuser)
    end

  end
end
