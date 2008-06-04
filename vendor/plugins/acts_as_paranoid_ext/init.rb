# http://pastie.caboo.se/200769
#
# extends acts_as_paranoid so that a has_many association proxy can
# take a dependent => :destroy! option and call destroy! on the associated
# records 

ActiveRecord::Associations::HasManyAssociation.class_eval do
  unless method_defined? :delete_records_with_paranoid
    def delete_records_with_paranoid(records)
      if @reflection.options[:dependent] == :destroy!
        records.each(&:destroy!)
      else
        delete_records_without_paranoid(records)
      end
    end
    alias_method_chain :delete_records, :paranoid
  end
end

ActiveRecord::Associations::ClassMethods.module_eval do
  unless method_defined? :configure_dependency_for_has_many_with_paranoid
    def configure_dependency_for_has_many_with_paranoid(reflection)
      if reflection.options[:dependent] == :destroy!
        method_name = "has_many_dependent_destroy_for_#{reflection.name}".to_sym
        define_method(method_name) do
          send("#{reflection.name}").each { |o| o.destroy! }
        end
        before_destroy method_name  
      else
        configure_dependency_for_has_many_without_paranoid(reflection)
      end
    end
    alias_method_chain :configure_dependency_for_has_many, :paranoid
  end
end