# CHANGES
# - cleanup code
# - removed deprecated methods
# - separated acts_as_nested_set from class methods
# - made root and roots class methods
# - fixed level (which returned wrong values)
# - fixed STI: save acts_as_nested_set class and use it to call find
# - added left and right to retrieve left and right siblings
# - made update_attributes! and update_attributes move the node when parent_id, left_id or right_id is given

module SymetrieCom
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      class UnauthorizedAssignment < ActiveRecord::ActiveRecordError
        def initialize(field)
          super "Unauthorized assignment to #{field}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
        end
      end

      def self.included(base)
        base.extend(ActMacro)
      end

      # better_nested_set ehances the core nested_set tree functionality provided in ruby_on_rails.
      #
      # This acts provides Nested Set functionality. Nested Set is a smart way to implement
      # an _ordered_ tree, with the added feature that you can select the children and all of their
      # descendents with a single query. The drawback is that insertion or move need some complex
      # sql queries. But everything is done here by this module!
      #
      # Nested sets are appropriate each time you want either an orderd tree (menus,
      # commercial categories) or an efficient way of querying big trees (threaded posts).
      #
      # == API
      # Methods names are aligned on Tree's ones as much as possible, to make replacment from one
      # by another easier, except for the creation:
      #
      # in acts_as_tree:
      #   item.children.create(:name => "child1")
      #
      # in acts_as_nested_set:
      #   # adds a new item at the "end" of the tree, i.e. with child.left = max(tree.right)+1
      #   child = MyClass.new(:name => "child1")
      #   child.save
      #   # now move the item to its right place
      #   child.move_to_child_of my_item
      #
      # You can use:
      # * move_to_child_of
      # * move_to_right_of
      # * move_to_left_of
      # and pass them an id or an object.
      #
      # Other methods added by this mixin are:
      # * +root+ - root item of the tree (the one that has a nil parent; should have left_column = 1 too)
      # * +roots+ - root items, in case of multiple roots (the ones that have a nil parent)
      # * +level+ - number indicating the level, a root being level 0
      # * +ancestors+ - array of all parents, with root as first item
      # * +self_and_ancestors+ - array of all parents and self
      # * +siblings+ - array of all siblings, that are the items sharing the same parent and level
      # * +self_and_siblings+ - array of itself and all siblings
      # * +children_count+ - count of all immediate children
      # * +children+ - array of all immediate childrens
      # * +all_children+ - array of all children and nested children
      # * +full_set+ - array of itself and all children and nested children
      #
      # These should not be useful, except if you want to write direct SQL:
      # * +nested_set_left+ - name of the left column passed on the declaration line
      # * +nested_set_right+ - name of the right column passed on the declaration line
      # * +nested_set_parent+ - name of the parent column passed on the declaration line
      #
      # recommandations:
      # Don't name your left and right columns 'left' and 'right': these names are reserved on most of dbs.
      # Usage is to name them 'lft' and 'rgt' for instance.
      #
      module ActMacro
        # Configuration options are:
        #
        # * +parent_column+ - specifies the column name to use for keeping the position integer (default: parent_id)
        # * +left_column+ - column name for left boundry data, default "lft"
        # * +right_column+ - column name for right boundry data, default "rgt"
        # * +text_column+ - column name for the title field (optional). Used as default in the
        #   {your-class}_options_for_select helper method. If empty, will use the first string field
        #   of your model class.
        # * +scope+ - restricts what is to be considered a list. Given a symbol, it'll attach "_id"
        #   (if that hasn't been already) and use that as the foreign key restriction. It's also possible
        #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
        #   Example: <tt>acts_as_nested_set :scope => 'todo_list_id = #{todo_list_id} AND completed = 0'</tt>
        def acts_as_nested_set(options = {})
          include SymetrieCom::Acts::NestedSet::InstanceMethods
          extend SymetrieCom::Acts::NestedSet::ClassMethods

          delegate :nested_set_left, :nested_set_right, :nested_set_parent, :nested_set_scope, :nested_set_class, :to => self
          delegate :root, :roots, :to => self

          if options[:scope].is_a?(Symbol)
            options[:scope] = "#{options[:scope]}_id".intern if options[:scope].to_s !~ /_id$/
            options[:scope] = %(#{options[:scope].to_s}.nil? ? "#{options[:scope].to_s} IS NULL" : "#{options[:scope].to_s} = \#{#{options[:scope].to_s}}")
          end

          defaults = { :parent_column => 'parent_id',
                       :left_column   => 'lft',
                       :right_column  => 'rgt',
                       :scope         => '1 = 1',
                       # it generally seems to be a bad idea to rely on the table to be present at class load time?
                       # :text_column   => columns.collect{|c| (c.type == :string) ? c.name : nil }.compact.first,
                       :class         => self }

          superclass_delegating_accessor :nested_set_options
          self.nested_set_options = defaults.merge options

          # no bulk assignment
          attr_protected  nested_set_left.intern, nested_set_right.intern, nested_set_parent.intern

          # no assignment to structure fields
          [nested_set_left, nested_set_right, nested_set_parent].each do |name|
            module_eval "def #{name}=(x) raise UnauthorizedAssignment.new(#{name}) end", __FILE__, __LINE__
          end
        end
      end

      module ClassMethods
        def nested_set_left; nested_set_options[:left_column] end
        def nested_set_right; nested_set_options[:right_column] end
        def nested_set_parent; nested_set_options[:parent_column] end
        def nested_set_scope; nested_set_options[:scope] end
        def nested_set_class; nested_set_options[:class] end

        alias :left_col_name :nested_set_left
        alias :right_col_name :nested_set_right
        alias :parent_col_name :nested_set_parent

        def find_with_nested_set_scope(*args)
          if nested_set_scope
            with_scope(:find => { :conditions => nested_set_scope } ) do
              find *args
            end
          else
            find *args
          end
        end

        # Returns the single root
        def root
          nested_set_class.find_with_nested_set_scope(:first, :conditions => "(#{nested_set_parent} IS NULL)")
        end

        # Returns roots when multiple roots (or virtual root, which is the same)
        def roots
          nested_set_class.find_with_nested_set_scope(:all, :conditions => "(#{nested_set_parent} IS NULL)", :order => "#{nested_set_left}")
        end
      end

      module InstanceMethods
        # on creation, set automatically lft and rgt to the end of the tree
        def before_create
          maxright = nested_set_class.maximum(nested_set_right, :conditions => nested_set_scope) || 0
          # adds the new node to the right of all existing nodes
          self[nested_set_left] = maxright + 1
          self[nested_set_right] = maxright + 2
        end

        def update_attributes(attrs)
          move_by_attributes(attrs)
          super attrs
        end

        def update_attributes!(attrs)
          move_by_attributes(attrs)
          super attrs
        end

        # Returns true if this is a root node.
        def root?
          parent_id = self[nested_set_parent]
          (parent_id == 0 || parent_id.nil?) && (self[nested_set_left] == 1) && (self[nested_set_right] > self[nested_set_left])
        end

        # Returns true is this is a child node
        def child?
          parent_id = self[nested_set_parent]
          !(parent_id == 0 || parent_id.nil?) && (self[nested_set_left] > 1) && (self[nested_set_right] > self[nested_set_left])
        end

        # order by left column
        def <=>(x)
          self[nested_set_left] <=> x[nested_set_left]
        end

        # Returns the parent
        def parent
          nested_set_class.find(self[nested_set_parent]) if self[nested_set_parent]
        end

        # Returns an array of all parents
        # Maybe 'full_outline' would be a better name, but we prefer to mimic the Tree class
        def ancestors
          nested_set_class.find_with_nested_set_scope(:all, :conditions => "(#{nested_set_left} < #{self[nested_set_left]} and #{nested_set_right} > #{self[nested_set_right]})", :order => nested_set_left )
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
          return [self] if self[nested_set_parent].nil? || self[nested_set_parent].zero?
          nested_set_class.find_with_nested_set_scope(:all, :conditions => "#{nested_set_parent} = #{self[nested_set_parent]}", :order => nested_set_left)
        end

        def left
          nested_set_class.find_with_nested_set_scope(:first, :conditions => "#{nested_set_right} = #{self[nested_set_left] - 1} AND #{nested_set_parent} = #{self[nested_set_parent]}")
        end

        def right
          nested_set_class.find_with_nested_set_scope(:first, :conditions => "#{nested_set_left} = #{self[nested_set_right] + 1} AND #{nested_set_parent} = #{self[nested_set_parent]}")
        end

        # Returns the level of this object in the tree
        # root level is 0
        def level
          return 0 if self[nested_set_parent].nil?
          sql = %Q( SELECT COUNT(t2.id) - 1 AS level
                    FROM #{nested_set_class.table_name} AS t1, #{nested_set_class.table_name} AS t2
                    WHERE t1.lft BETWEEN t2.lft AND t2.rgt AND t1.id = #{id} AND #{nested_set_scope} )
          nested_set_class.count_by_sql sql
        end

        # Returns the number of nested children of this object.
        def children_count
          return (self[nested_set_right] - self[nested_set_left] - 1) / 2
        end

        # Returns a set of itself and all of its nested children
        # Pass :exclude => item, or id, or [items or id] to exclude some parts of the tree
        def full_set(options = {})
          return [self] if new_record? or self[nested_set_right]-self[nested_set_left] == 1
          [self] + all_children(options)
        end

        # Returns a set of all of its children and nested children
        # Pass :exclude => item, or id, or [items or id] to exclude some parts of the tree
        def all_children(options = {})
          conditions = "(#{nested_set_left} > #{self[nested_set_left]}) and (#{nested_set_right} < #{self[nested_set_right]})"
          if options[:exclude]
            transaction do
              # exclude some items and all their children
              options[:exclude] = [options[:exclude]] if !options[:exclude].is_a?(Array)
              # get objects for ids
              options[:exclude].collect! {|s| s.is_a?(nested_set_class) ? s : nested_set_class.find(s)}
              # get all subtrees and flatten the list
              exclude_list = options[:exclude].map{|e| e.full_set.map{|ee| ee.id}}.flatten.uniq
              conditions += " AND id NOT IN (#{exclude_list.join(',')})" unless exclude_list.empty?
            end
          end
          nested_set_class.find_with_nested_set_scope(:all, :conditions => conditions, :order => nested_set_left)
        end

        # Returns a set of only this entry's immediate children
        def children
          nested_set_class.find_with_nested_set_scope(:all, :conditions => "#{nested_set_parent} = #{self.id}", :order => nested_set_left)
        end

        # Prunes a branch off of the tree, shifting all of the elements on the right
        # back to the left so the counts still work.
        def before_destroy
          return if self[nested_set_right].nil? || self[nested_set_left].nil?
          diff = self[nested_set_right] - self[nested_set_left] + 1

          nested_set_class.transaction {
            nested_set_class.delete_all "#{nested_set_scope} AND #{nested_set_left} > #{self[nested_set_left]} and #{nested_set_right} < #{self[nested_set_right]}"
            nested_set_class.update_all "#{nested_set_left} = (#{nested_set_left} - #{diff})",  "#{nested_set_scope} AND #{nested_set_left} >= #{self[nested_set_right]}"
            nested_set_class.update_all "#{nested_set_right} = (#{nested_set_right} - #{diff} )",  "#{nested_set_scope} AND #{nested_set_right} >= #{self[nested_set_right]}"
          }
        end

        def move_by_attributes(attrs)
          return unless attrs

          move_left = attrs.has_key? 'left_id'
          move_right = attrs.has_key? 'right_id'

          attrs.each{|key, value| attrs.delete(key) if value == 'null' }

          parent_id, left_id, right_id = [nested_set_parent, 'left_id', 'right_id'].collect do |key|
            value = attrs.delete(key)
            value.blank? ? value : value.to_i
          end

          if move_left && left_id.blank?
            siblings = parent_id ? nested_set_class.find(parent_id).children : roots
            left_id, right_id = nil, siblings.first.id if siblings.first
          end

          if move_right && right_id.blank?
            siblings = parent_id ? nested_set_class.find(parent_id).children : roots
            left_id, right_id = siblings.last.id, nil if siblings.last
          end

          move_to_child_of parent_id unless parent_id.blank? or parent_id == self.parent_id
          move_to_right_of left_id   unless left_id.blank? or left_id == id
          move_to_left_of right_id   unless right_id.blank? or right_id == id
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
          raise ActiveRecord::ActiveRecordError, "You cannot move a new node" if self.id.nil?

          # use shorter names for readability: current left and right
          cur_left, cur_right = self[nested_set_left], self[nested_set_right]

          # extent is the width of the tree self and children
          extent = cur_right - cur_left + 1

          # load object if node is not an object
          target = nested_set_class.find(target) unless nested_set_class === target
          target_left, target_right = target[nested_set_left], target[nested_set_right]

          # detect impossible move
          if ((cur_left <= target_left) && (target_left <= cur_right)) or ((cur_left <= target_right) && (target_right <= cur_right))
            raise ActiveRecord::ActiveRecordError, "Impossible move, target node cannot be inside moved tree."
          end

          # compute new left/right for self
          if position == :child
            if target_left < cur_left
              new_left  = target_left + 1
              new_right = target_left + extent
            else
              new_left  = target_left - extent + 1
              new_right = target_left
            end
          elsif position == :left
            if target_left < cur_left
              new_left  = target_left
              new_right = target_left + extent - 1
            else
              new_left  = target_left - extent
              new_right = target_left - 1
            end
          elsif position == :right
            if target_right < cur_right
              new_left  = target_right + 1
              new_right = target_right + extent
            else
              new_left  = target_right - extent + 1
              new_right = target_right
            end
          else
            raise ActiveRecord::ActiveRecordError, "Position should be either left or right ('#{position}' received)."
          end

          # boundaries of update action
          b_left, b_right = [cur_left, new_left].min, [cur_right, new_right].max

          # Shift value to move self to new position
          shift = new_left - cur_left

          # Shift value to move nodes inside boundaries but not under self_and_children
          updown = (shift > 0) ? -extent : extent

          # change nil to NULL for new parent
          if position == :child
            new_parent = target.id
          else
            new_parent = target[nested_set_parent].nil? ? 'NULL' : target[nested_set_parent]
          end

          # update and that rules
          sql = %Q( #{nested_set_left} = CASE \
                      WHEN #{nested_set_left} BETWEEN #{cur_left} AND #{cur_right} THEN #{nested_set_left} + #{shift} \
                      WHEN #{nested_set_left} BETWEEN #{b_left} AND #{b_right} THEN #{nested_set_left} + #{updown} \
                      ELSE #{nested_set_left} END, \

                    #{nested_set_right} = CASE \
                      WHEN #{nested_set_right} BETWEEN #{cur_left} AND #{cur_right} THEN #{nested_set_right} + #{shift} \
                      WHEN #{nested_set_right} BETWEEN #{b_left} AND #{b_right} THEN #{nested_set_right} + #{updown} \
                      ELSE #{nested_set_right} END, \

                    #{nested_set_parent} = CASE \
                      WHEN #{nested_set_class.primary_key} = #{self.id} THEN #{new_parent} \
                      ELSE #{nested_set_parent} END )

          nested_set_class.update_all sql, nested_set_scope
          self.reload
        end
      end
    end
  end
end
