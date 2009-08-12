# Heavily inspired by Noel Rappin's "More Named Scope Awesomeness"
# http://www.pathf.com/blogs/2008/06/more-named-scope-awesomeness/

module HasFilter
  # # raised when filter_by is called with an attribute that has not been
  # # whitelisted for being filtered
  # class IllegalAttributeAccessError < ActiveRecordError
  #   attr_reader :attribute
  #   def initialize(attribute)
  #     @attribute = attribute
  #     super "Tried to filter by #{attribute.inspect}. This attribute has not been whitelisted for filtering."
  #   end
  # end

  module ActiveRecord
    module ActMacro
      def has_filter(*filters)
        return if has_filter?
        include InstanceMethods
        extend ClassMethods

        class_inheritable_accessor :filter_chain
        self.filter_chain = ::HasFilter::Filter::Chain.build(self, filters)

        scopes = { # FIXME make these extensible
          :is                  => ["=" ],
          :is_not              => ["<>"],
          :contains            => ["LIKE",     "%%%s%"],
          :does_not_contain    => ["NOT LIKE", "%%%s%"],
          :starts_with         => ["LIKE",     "%s%"  ],
          :does_not_start_with => ["NOT LIKE", "%s%"  ],
          :ends_with           => ["LIKE",     "%%%s" ],
          :does_not_end_with   => ["NOT LIKE", "%%%s" ] }
          # FIXME add these
          # created_before, created_after
          # updated_before, updated_after

        scopes.each do |name, scope|
          named_scope name, lambda { |column, value| filter_scope(column, Array(value), *scope) }
        end

        named_scope :contains_all, contains_all_scope
        named_scope :categorized, categorized_scope
      end

      def filtered(filters)
        scope = scope(:find).blank? ? self : scoped(scope(:find))
        filter_chain.select(filters).scope(scope)
      end

      def has_filter?
        included_modules.include? HasFilter::ActiveRecord::InstanceMethods
      end
    end

    module ClassMethods
      protected
        def contains_all_scope
          lambda { |column, values|
            values = values.split(' ') if values.is_a?(String)
            values.map! { |value| "%#{value}%" }
            { :conditions => [(["#{column} LIKE ?"] * values.size).join(' AND '), *values] }
          }
        end

        def categorized_scope
          lambda { |*ids|
            { :select => "#{table_name}.*, COUNT(*) AS count",
              :joins => { :categorizations => :category },
              :conditions => ["#{reflect_on_association(:categories).table_name}.id IN(?)", ids],
              :group => "#{table_name}.id HAVING count >= #{ids.size}" }
          }
        end

        def filter_scope(column, values, operator, format = nil)
          query = (["#{column} #{operator} ?"] * values.size)
          # FIXME why did we have .map($:downcase) here ?
          values = values.map{ |value| format ? format % value : value } # .map(&:downcase)
          scope = { :conditions => [query.join(' OR '), *values] }
          translated?(column) ? merge_globalization_scope(scope) : scope
        end

        def translated?(column)
          # FIXME really should be in globalize
          respond_to?(:globalize_options) && globalize_options[:translated_attributes].include?(column.to_sym)
        end
        
        def merge_globalization_scope(scope)
          if scope.has_key?(:conditions)
            scope[:conditions][0] += " AND current = ?"
            scope[:conditions] << true
            scope.merge!(:joins => :globalize_translations, :group => "#{self.table_name}.id")
          else
            scope.merge!(:joins => :globalize_translations, :group => "#{self.table_name}.id", :conditions => ['current = ?', true])
          end
        end
    end

    module InstanceMethods
    end
  end
end