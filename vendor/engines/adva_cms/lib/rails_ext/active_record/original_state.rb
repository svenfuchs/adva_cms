ActiveRecord::Base.class_eval do
  attr_reader :original_state

  define_method(:after_initialize){} unless method_defined?(:after_initialize)
  def after_initialize_with_original_state
    @original_state = returning self.dup do |clone|
      clone.id = id
      clone.instance_variable_set :@attributes, attributes.dup
      clone.instance_variable_set :@changed_attributes, changed_attributes.dup
      clone.instance_variable_set :@new_record, new_record?
    end
    after_initialize_without_original_state
  end
  alias_method_chain :after_initialize, :original_state
  
  def state_changes
    if frozen?
      [:deleted]
    elsif original_state.new_record?
      [:created]
    elsif original_state.attributes != attributes
      [:updated]
    else
      []
    end
  end
  
  # def just_created?
  #   previous_state.new_record?
  # end
end