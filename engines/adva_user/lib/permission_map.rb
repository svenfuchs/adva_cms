# TODO - muuuuch of this could be done so much nicer


# Manages permissions that map actions to roles.
#
# Ensures the given actions are arrays, invert the role => action hash
# to a action => role hash while expanding the actions array to keys,
# and expand the action key :all to the default actions.
#
# E.g.:
#
#   :comment => {:user => :create, :admin => [:edit, :delete]}
#
# becomes:
#
#   :comment => {:create => :user, :edit => :admin, :delete => :admin}

class PermissionMap < Hash
  def default_actions
    [:show, :create, :update, :destroy]
  end

  def initialize(permissions)
    permissions.clone.each do |type, roles|
      roles.each do |role, actions|
        actions = actions == :all ? default_actions : Array(actions)
        set type, Hash[*(actions.zip [role] * actions.size).flatten]
      end
    end
  end

  def set(type, permissions)
    self[type] ||= {}
    self[type].update permissions
  end

  def sorted
    sorted = ActiveSupport::OrderedHash.new
    sorted_keys.each do |type|
      roles = self[type]
      # put default_actions to the front, sort the rest
      # then only use keys that were present in the original key set
      keys = default_actions + sorted_keys(roles.keys - default_actions) & roles.keys
      (keys).each do |key|
        sorted[type] ||= ActiveSupport::OrderedHash.new
        sorted[type][key] = self[type][key]
      end
    end
    sorted
  end

  def sorted_keys(keys = nil)
    keys ||= self.keys
    keys.map(&:to_s).sort.map(&:to_sym)
  end

  def update(other)
    merged = self.dup
    other.each do |type, permissions|
      permissions.each do |action, role|
        type = type.to_sym
        action = action.to_sym
        self[type] ||= {}
        self[type][action] ||= {}
        self[type][action] = role.to_sym
      end
    end
    merged
  end
end