# TODO move to some rails specific adapter in Rbac?

module ActionController
  class RoleRequired < SecurityError
    attr_accessor :required_role
    def initialize(role_types, action, type)
      @required_roles = role_types
      @action = action
      @type = type
      super I18n.t(:'adva.roles.errors.messages.role_required', :roles => role_types)
    end
  end

  module GuardsPermissions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def guards_permissions(type, options = {})
        return if guards_permissions?
        include InstanceMethods
        extend ClassMethods

        helper_method :has_permission?

        class_inheritable_accessor :action_map
        set_action_map options.except(:only, :except)

        before_filter(options.slice(:only, :except)) do |controller|
          controller.guard_permission(type)
        end
      end

      def guards_permissions?
        included_modules.include? InstanceMethods
      end
    end

    module ClassMethods
      # maps controller actions to (virtual) model actions that are referenced
      # by the roles system
      def set_action_map(map)
        self.action_map = { :index => :show, :edit => :update, :new => :create }
        map.each do |target, actions|
          Array(actions).each{|action| self.action_map[action] = target }
        end
      end
    end

    module InstanceMethods
      def guard_permission(*args)
        type = args.pop
        action = args.pop || map_from_controller_action

        # TODO :show permissions do not make any sense right now, so we
        # completely deactivate them
        # return if action.to_sym == :show

        unless has_permission?(action, type)
          role_types = current_resource.authorizing_role_types_for(:"#{action} #{type}")
          raise RoleRequired.new(role_types, action, type)
        end
      end

      def has_permission?(action, type)
        action = :"#{action} #{type}"
        user = current_user || User.anonymous
        user.has_permission?(action, current_resource)
      end

      def map_from_controller_action
        action_map[params[:action].to_sym] || params[:action].to_sym
      end
    end
  end
end
