module ActiveRecord
  module NestedSet
    module ActMacro
      def acts_as_nested_set(options = {})
        return if acts_as_nested_set?
        include ActiveRecord::NestedSet::InstanceMethods
        extend ActiveRecord::NestedSet::ClassMethods

        define_callbacks :before_move, :after_move

        before_create  :init_as_node
        before_destroy :prune_branch
        belongs_to :parent, :class_name => self.name

        default_scope :order => 'lft'

        klass = options[:class] || self
        scopes = Array(options[:scope]).map { |s| s.to_s !~ /_id$/ ? :"#{s}_id" : s }
        conditions = lambda { |s| scopes.inject({}) { |c, attr| c.merge(attr => s[attr]) } }

        named_scope :nested_set, lambda { |s| { :conditions => conditions.call(s) } } do
          define_method(:scope_columns) { scopes }
          define_method(:klass)  { klass }
        end
      end

      def acts_as_nested_set?
        included_modules.include?(ActiveRecord::NestedSet::InstanceMethods)
      end
    end

    module ClassMethods
      # Returns the single root
      def root(*args)
        nested_set(*args).first(:conditions => { :parent_id => nil })
      end

      # Returns roots when multiple roots (or virtual root, which is the same)
      def roots(*args)
        nested_set(*args).scoped(:conditions => { :parent_id => nil } )
      end
    end

    module InstanceMethods
      def nested_set
        @nested_set ||= self.class.base_class.nested_set(self)
      end

      def update_attributes(attrs) # dangerous. the class itself could implement this, too. what's a better way?
        move_by_attributes(attrs)
        super attrs
      end

      def update_attributes!(attrs)
        move_by_attributes(attrs)
        super attrs
      end

      # Returns true if this is a root node.
      def root?
        parent_id.blank?
      end

      # Returns true is this is a child node
      def child?
        !root?
      end

      # order by left column
      def <=>(other)
        lft <=> other.lft
      end

      # Returns root
      def root
        root? ? self : ancestors.first
      end

      # Returns the parent
      def parent
        nested_set.klass.find(parent_id) unless root?
      end

      # Returns the array of all parents and self
      def self_and_ancestors
        ancestors + [self]
      end

      # Returns an array of all parents
      def ancestors
        nested_set.scoped(:conditions => "lft < #{lft} AND rgt > #{rgt}")
      end

      # Returns a set of itself and all of its nested children.
      def self_and_descendants
        [self] + descendants
      end

      # Returns a set of all of its children and nested children.
      def descendants
        rgt - lft == 1 ? []  : nested_set.scoped(:conditions => ['lft > ? AND rgt < ?', lft, rgt])
      end

      # Returns a set of only this entry's immediate children including self
      def self_and_children
        [self] + children
      end

      # Returns a set of only this entry's immediate children
      def children
        rgt - lft == 1 ? []  : nested_set.scoped(:conditions => { :parent_id => id })
      end

      # Returns the number of nested children of this object.
      def children_count
        return (rgt - lft - 1) / 2
      end

      # Returns the level of this object in the tree, root level is 0
      def level
        return parent_id.nil? ? 0 : ancestors.count
      end

      # Returns the array of all children of the parent, included self
      def self_and_siblings
        nested_set.scoped(:conditions => { :parent_id => parent_id })
      end

      # Returns the array of all children of the parent, except self
      def siblings
        without_self self_and_siblings
      end

      # Returns the lefthand sibling
      def left
        nested_set.first :conditions => { :rgt => lft - 1 }
      end

      # Returns the righthand sibling
      def right
        nested_set.first :conditions => { :lft => rgt + 1 }
      end

      def move_by_attributes(attrs)
        return unless attrs.detect { |key, value| [:parent_id, :left_id, :right_id].include?(key.to_sym) }

        attrs.symbolize_keys!
        attrs.each { |key, value| attrs[key] = nil if value == 'null' }

        parent_id = attrs[:parent_id] ? attrs[:parent_id] : self.parent_id
        parent = parent_id.blank? ? nil : nested_set.klass.find(parent_id)

        # if left_id is given but blank, set right_id to leftmost one
        if attrs.has_key?(:left_id) && attrs[:left_id].blank?
          attrs.delete(:left_id)
          siblings = parent ? parent.children : self.class.roots(self)
          attrs[:right_id] = siblings.first.id if siblings.first
        end

        # if right_id is given but blank, set left_id to rightmost one
        if attrs.has_key?(:right_id) && attrs[:right_id].blank?
          attrs.delete(:right_id)
          siblings = parent ? parent.children : self.class.roots(self)
          attrs[:left_id] = siblings.last.id if siblings.last
        end

        parent_id, left_id, right_id = [:parent_id, :left_id, :right_id].map do |key|
          value = attrs.delete(key)
          value.blank? ? nil : value.to_i
        end

        move_to_right_of(left_id)   if left_id and left_id != id
        move_to_left_of(right_id)   if right_id and right_id != id
        move_to_child_of(parent_id) if parent_id and parent_id != self.parent_id
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

        # on creation set lft and rgt to the end of the tree
        def init_as_node
          max_right = nested_set.maximum(:rgt) || 0
          # adds the new node to the right of all existing nodes
          self.lft = max_right + 1
          self.rgt = max_right + 2
        end

        # Prunes a branch off of the tree, shifting all of the elements on the right
        # back to the left so the counts still work.
        def prune_branch
          return if rgt.nil? || lft.nil?
          diff = rgt - lft + 1

          self.class.transaction {
            nested_set.delete_all "lft > #{lft} AND rgt < #{rgt}"
            nested_set.update_all "lft = (lft - #{diff})",   "lft >= #{rgt}"
            nested_set.update_all "rgt = (rgt - #{diff} )",  "rgt >= #{rgt}"
          }
        end
        
        def same_scope?(other)
          nested_set.scope_columns.all? { |attr| self.send(attr) == other.send(attr) }
        end

        def without_self(scope)
          scope.scoped :conditions => ["#{self.class.table_name}.id <> ?", id]
        end

        def move_to(target, position)
          return if callback(:before_move) == false
          transaction do
            target.reload_nested_set if target.is_a?(nested_set.klass)
            self.reload_nested_set

            target = nested_set.klass.find(target) unless target.is_a?(ActiveRecord::Base)
            protect_impossible_move!(position, target)
            
            bound = case position
              when :child;  target.rgt
              when :left;   target.lft
              when :right;  target.rgt + 1
              when :root;   1
            end
            
            if bound > rgt
              bound -= 1
              other_bound = rgt + 1
            else
              other_bound = lft - 1
            end
 
            # there would be no change
            return if bound == rgt || bound == lft
          
            # we have defined the boundaries of two non-overlapping intervals, 
            # so sorting puts both the intervals and their boundaries in order
            a, b, c, d = [lft, rgt, bound, other_bound].sort
 
            new_parent_id = case position
              when :child;  target.id
              when :root;   nil
              else          target.parent_id
            end
            
            # update and that rules
            sql = %( lft = CASE \
                       WHEN lft BETWEEN :a AND :b THEN lft + :d - :b \
                       WHEN lft BETWEEN :c AND :d THEN lft + :a - :c \
                       ELSE lft END, \
                   
                     rgt = CASE \
                       WHEN rgt BETWEEN :a AND :b THEN rgt + :d - :b \
                       WHEN rgt BETWEEN :c AND :d THEN rgt + :a - :c \
                       ELSE rgt END, \
                   
                     parent_id = CASE \
                       WHEN id = :id THEN :new_parent_id \
                       ELSE parent_id END )

            args = { :a => a, :b => b, :c => c, :d => d, :id => id, :new_parent_id => new_parent_id }
            nested_set.klass.update_all [sql, args], nested_set.proxy_options[:conditions]

            target.reload_nested_set if target
            self.reload_nested_set
          end
        end

        # reload left, right, and parent
        def reload_nested_set
          reload :select => 'lft, rgt, parent_id'
        end

        def protect_impossible_move!(position, target)
          positions = [:child, :left, :right, :root]
          impossible_move! "Position must be one of #{positions.inspect} but is '#{position.inspect}'." unless 
            positions.include?(position)
          impossible_move! "A new node can not be moved" if new_record?
          impossible_move! "A node can't be moved to itself" if self == target
          impossible_move! "A node can't be moved to a different scope" unless same_scope?(target)
          # impossible_move! "A node can't be moved to a descendant." if (lft..rgt).include?(target.lft..target.rgt)
        end
        
        def impossible_move!(message)
          raise ActiveRecord::ActiveRecordError, "Impossible move: #{message}"
        end
    end
  end
end

ActiveRecord::Base.send :extend, ActiveRecord::NestedSet::ActMacro