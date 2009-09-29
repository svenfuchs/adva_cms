module ActionController

  # Module automatically mixed into the all controllers making the
  # application of authentication easy. See
  # Login::ControllerIntegration::ClassMethods for how to apply
  # authentication.
  module AuthenticateUser
    def self.included(target)
      target.extend(ClassMethods)
      target.send(:include, InstanceMethods)
      target.helper_method(:logged_in?, :authenticated?)
    end

    # Methods available as macro-style methods on any controller
    module ClassMethods

      # Sets up the controller so that authentication is required. If
      # the user is not authenticated then they will be redirected to
      # the login screen.
      #
      # The page requested will be saved so that once the login has
      # occured they will be sent back to the page they first
      # requested. If no page was requested (they went to the login
      # page directly) then they will be directed to profiles/home
      # after login which is a placeholder for the app to override.
      #
      # Options given are passed directly to the before_filter method
      # so feel free to provide :only and :except options.
      def authentication_required(*options)
        before_filter :require_authentication, options
      end

      # Will remove authentication from certain actions. Options given
      # are passed directly to skip_before_filter so feel free to use
      # :only and :except options.
      #
      # This method is useful in cases where you have locked down the
      # entire application by putting authentication_required in your
      # ApplicationController but then want to open an action back up
      # in a specific controller.
      def no_authentication_required(*options)
        skip_before_filter :require_authentication, options
      end
    end

    # Methods callable from within actions
    module InstanceMethods
      def authenticate_user(credentials)
        returning User.authenticate(credentials) do |user|
          if user
            # prevent session hijacking - unnecessary according to http://dev.rubyonrails.org/ticket/10108
            # reset_session_except :return_location
            session[:uid] = user.id
            set_user_cookie!(user)
          end
        end
      end

      # Will retrieve the current_user. Will not force a login but
      # simply load the current user if a person is logged in. If
      # you need the user object loaded with extra options (such as
      # eager loading) then create a private method called
      # "user_find_options" on your controller that returns a hash
      # of the find options you want.
      #
      # This method will also inform the models of the current user
      # if the current user is logged in and the "User" class responds
      # to the class method current_user=. This is a nice way to
      # communciate the current user down to the model level for
      # model-level security. This means you will want to call this
      # method at least once before using the model-level security.
      # Usually you will call it in a before filter. This method is
      # called automatically when authentication_required is applied to
      # an action.
      def current_user
        @current_user ||= begin
          # Check for session[:uid] here? That would mean that for token auth the
          # user always needs to be logged out (e.g. in UserController#create).
          # Looks a bit more robust this way:
          try_login
          if session && session[:uid]
            user = find_current_user
            set_user_cookie!(user)
            user
          end
        end
      end

      def authenticated?
        !!current_user
      end
      alias :logged_in? :authenticated?

      # killed this because it's just the wrong way to do it
      #
      # # Will store the current params so that we can return here on
      # # successful login. If you want to redirect to the login yourself
      # # (perhaps you are applying your own security instead of just
      # # determining if the user is logged in) then you will want to
      # # call this before issuing your redirect to the login screen.
      # def store_return_location
      #   session[:return_location] = params
      # end

      private

        # Will actually test to see if the user is authorized
        def require_authentication

          # No matter what the app does a user can always login, forgot
          # password and register. The controllers provided by this
          # plugin alreaddy have these controllers/actions on an
          # exception list but this prevents a mistake an overridden
          # controller from preventing the normal login behavior.
          %w(session password user).each do |c|
  	        %w(new create).each do |a|
              return if (controller_name == c) && (action_name == a)
            end
  	      end

          # If we cannot get the current user store the requested page
          # and send them to the login page.
          if current_user.nil? or current_user.anonymous?
            redirect_to login_url(:return_to => request.url) and false
          end
        end

        def logout
          reset_session
          forget_me!
        end

        def forget_me!
          cookies[:remember_me] = nil
          cookies[:uid] = nil
          cookies[:uname] = nil
        end

        def remember_me!
          token = current_user.assign_token!('remember me')
          cookies[:remember_me] = { :value => "#{current_user.id};#{token}", :expires => 10.years.from_now }
        end

        def set_user_cookie!(user = current_user)
          if user
            cookies[:uid] = user.id.to_s
            cookies[:uname] = user.name
          end
        end

        # There are a few ways that a user can login without going through
        # a login screen. These methods all rely on authenticating with
        # the information given in the request. If any of these methods
        # are successful then session[:uid] will be set with the current
        # user id and current_user will return the current user
        def try_login
          if user = http_auth_login || validation_login || remember_me_login
            session[:uid] = user.id
          end
        end

        # Will attempt to authenticate with HTTP Auth. HTTP Auth will not
        # be required. We are just checking if it is provided mainly for
        # RESTful requests.
        def http_auth_login
          # FIXME: Implement
        end

        # Will use the URL param :token to see if we can do a token
        # authentication.
        def validation_login
          validate_token User, params[:token]
        end

        # Will check for a :remember_me cookie for a token that will
        # authenticate the user.
        def remember_me_login
          validate_token User, cookies[:remember_me]
        end

        # The tokens are stored in various places as id;token. This method
        # will split that out and validate it. If everything is successful
        # then the user object is returned. Otherwise nil is returned.
        # The full token should be passed in.
        def validate_token(klass, token, options = {})
          return nil if token.blank?
          return nil unless token =~ /\;/

          uid, token = token.split ';'
          if object = klass.find_by_id(uid) # , authentication_find_options[klass] || {}
            return object if object.authenticate(token)
          end
          nil
        end

        def find_current_user
          User.find_by_id(session[:uid], authentication_find_options[User])
        end

        # Override this in the controller if you want to pass in
        # additional options when loading the current user (for example
        # eager loading of relationships)
        def authentication_find_options
          {}
        end

    end
  end
end
