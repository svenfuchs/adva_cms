module ActiveRecord
  module NestedSet
    module ActMacro
      def acts_as_nested_set(options = {})
        return if acts_as_nested_set?
        include ActiveRecord::NestedSet::InstanceMethods
        extend ActiveRecord::NestedSet::ClassMethods

        belongs_to :parent, :class_name => self.name
        delegate :root, :roots, :to => :nested_set

        klass = options[:class] || self
        scopes = Array(options[:scope]).map { |s| s.to_s !~ /_id$/ ? :"#{s}_id" : s }
        condition = lambda { |s|
          Hash[*scopes.map { |scope| [scope, s.is_a?(Hash) ? s[scope] : s.send(scope)] }.flatten] if scopes.size 
        }
        
        named_scope :nested_set, lambda { |s| { :order => "lft", :conditions => condition.call(s) } } do
          define_method(:scopes) { scopes }
          define_method(:scope)  { |s| condition.call(s) }
          define_method(:klass)  { klass }
          define_method(:root)   { first(:conditions => "parent_id IS NULL") }
          define_method(:roots)  { all(:conditions => "parent_id IS NULL") }
        end
      end

      def acts_as_nested_set?
        included_modules.include?(ActiveRecord::NestedSet::InstanceMethods)
      end
    end

    module ClassMethods
      # Returns the single root
      def root(*args)
        nested_set(*args).root
      end

      # Returns roots when multiple roots (or virtual root, which is the same)
      def roots(*args)
        nested_set(*args).roots
      end
    end

    module InstanceMethods
      def nested_set
        self.class.nested_set(self)
      end
      
      # on creation set lft and rgt to the end of the tree
      def before_create
        max_right = nested_set.maximum(:rgt) || 0
        # adds the new node to the right of all existing nodes
        self.lft = max_right + 1
        self.rgt = max_right + 2
      end

      def update_attributes(attrs) # dangerous. the class itself could also implement this method is there a better way?
        move_by_attributes(attrs)
        super attrs
      end

      def update_attributes!(attrs)
        move_by_attributes(attrs)
        super attrs
      end

      # Returns true if this is a root node.
      def root?
        parent_id.blank? # && (lft == 1) && (rgt > lft) # hu? why not just look at the parent_id?
      end

      # Returns true is this is a child node
      def child?
        !parent_id.blank? # && (lft > 1) && (rgt > lft) # hu? why not just look at the parent_id?
      end

      # order by left column
      def <=>(other)
        lft <=> other.lft
      end

      # Returns the parent
      def parent
        nested_set.klass.find(parent_id) unless parent_id.blank?
      end

      # Returns an array of all parents
      # Maybe 'full_outline' would be a better name, but we prefer to mimic the Tree class
      def ancestors
        nested_set.all(:conditions => "lft < #{lft} AND rgt > #{rgt}")
      end

      # Returns the array of all parents and self
      def self_and_ancestors
        ancestors + [self]
      end

      # Returns the array of all children of the parent, except self
      def siblings
        self_and_siblings - [self]
      end

      # Returns the array of all children of the parent, included self
      def self_and_siblings
        parent_id.blank? ? nested_set.roots : nested_set.all(:conditions => "parent_id = #{parent_id}")
      end

      def left
        nested_set.first :conditions => "rgt = #{lft - 1}"
      end

      def right
        nested_set.first(:conditions => "lft = #{rgt + 1}")
      end

      # Returns the level of this object in the tree, root level is 0
      def level
        table = self.class.table_name
        scope = nested_set.scopes.map { |s| "#{table}.#{s} = t2.#{s}" }
        condition = "#{table}.lft BETWEEN t2.lft AND t2.rgt AND #{table}.id = #{id}"
        condition += " AND " + scope.join(' AND ') unless scope.empty?
        nested_set.count(:select => "t2.id", :from => "#{table}, #{table} AS t2", :conditions => condition) - 1
      end

      # Returns the number of nested children of this object.
      def children_count
        return (rgt - lft - 1) / 2
      end

      # Returns a set of itself and all of its nested children.
      def full_set
        (rgt - lft) == 1 ? [self]  : [self] + all_children
      end

      # Returns a set of all of its children and nested children.
      def all_children
        nested_set.all(:conditions => "lft > #{lft} AND rgt < #{rgt}")
      end

      # Returns a set of only this entry's immediate children
      def children
        nested_set.all(:conditions => "parent_id = #{id}")
      end

      # Prunes a branch off of the tree, shifting all of the elements on the right
      # back to the left so the counts still work.
      def before_destroy
        return if rgt.nil? || lft.nil?
        diff = rgt - lft + 1

        self.class.transaction {
          nested_set.delete_all "lft > #{lft} AND rgt < #{rgt}"
          nested_set.update_all "lft = (lft - #{diff})",   "lft >= #{rgt}"
          nested_set.update_all "rgt = (rgt - #{diff} )",  "rgt >= #{rgt}"
        }
      end

      def move_by_attributes(attrs)
        return unless attrs
        attrs.symbolize_keys!
        attrs.reject! { |key, value| value == 'null' }

        # if left_id is given but blank, set right_id to leftmost one
        if attrs.has_key?(:left_id) && attrs[:left_id].blank?
          s = self_and_siblings
          attrs[:right_id] = s.first.id if s.first
        end

        # if right_id is given but blank, set left_id to rightmost one
        if attrs.has_key?(:right_id) && attrs[:right_id].blank?
          s = self_and_siblings
          attrs[:left_id] = s.last.id if s.last
        end

        parent_id, left_id, right_id = [:parent_id, :left_id, :right_id].map do |key|
          value = attrs.delete(key)
          value.blank? ? nil : value.to_i
        end

        move_to_child_of(parent_id) if parent_id and parent_id != self.parent_id
        move_to_right_of(left_id)   if left_id and left_id != id
        move_to_left_of(right_id)   if right_id and right_id != id
      end

      # Move the node to the left of another node
      def move_to_left_of(node)
        self.move_to node, :left
      end

      # Move the node to the left of another node
      def move_to_right_of(node)
        self.move_to node, :right
      end

      # Move the node to the child of another node
      def move_to_child_of(node)
        self.move_to node, :child
      end

      protected
        def move_to(target, position)
          target = nested_set.klass.find(target) unless target.is_a?(ActiveRecord::Base)

          raise ActiveRecord::ActiveRecordError, "You cannot move a new node" if new_record?
          protect_impossible_move!(target)

          new_parent_id = (position == :child ? target.id : target.parent_id) || 'NULL'

          # number of self_and_children nodes
          spread = rgt - lft + 1

          # compute new lft/rgt for self
          case position
          when :child
            if target.lft < lft
              new_lft = target.lft + 1
              new_rgt = target.lft + spread
            else
              new_lft = target.lft - spread + 1
              new_rgt = target.lft
            end
          when :left
            if target.lft < lft
              new_lft = target.lft
              new_rgt = target.lft + spread - 1
            else
              new_lft = target.lft - spread
              new_rgt = target.lft - 1
            end
          when :right
            if target.rgt < rgt
              new_lft = target.rgt + 1
              new_rgt = target.rgt + spread
            else
              new_lft = target.rgt - spread + 1
              new_rgt = target.rgt
            end
          else
            raise ActiveRecord::ActiveRecordError, "Position must be one of: :child, :left, :right (was #{position.inspect})."
          end

          # boundaries of update action
          outer_lft, outer_rgt = [lft, new_lft].min, [rgt, new_rgt].max

          # distance from current to new position
          shift = new_lft - lft

          # shift value for nodes that are inside boundaries but not under self_and_children
          updown = (shift > 0) ? -spread : spread

          # update and that rules
          sql = %Q( lft = CASE \
                      WHEN lft BETWEEN #{lft} AND #{rgt} THEN lft + #{shift} \
                      WHEN lft BETWEEN #{outer_lft} AND #{outer_rgt} THEN lft + #{updown} \
                      ELSE lft END, \

                    rgt = CASE \
                      WHEN rgt BETWEEN #{lft} AND #{rgt} THEN rgt + #{shift} \
                      WHEN rgt BETWEEN #{outer_lft} AND #{outer_rgt} THEN rgt + #{updown} \
                      ELSE rgt END, \

                    parent_id = CASE \
                      WHEN id = #{id} THEN #{new_parent_id} \
                      ELSE parent_id END )

          nested_set.klass.update_all sql, nested_set.scope(self)
          self.reload
        end

        def protect_impossible_move!(target)
          if ((lft <= target.lft) && (target.lft <= rgt)) or ((lft <= target.rgt) && (target.rgt <= rgt))
            raise ActiveRecord::ActiveRecordError, "Impossible move, target node cannot be inside moved tree."
          end
        end
    end
  end
end

ActiveRecord::Base.send :extend, ActiveRecord::NestedSet::ActMacro