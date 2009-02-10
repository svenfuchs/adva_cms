ActionController::Base.class_eval do
  class << self
    def renders_with_error_proc(error_proc_name)
      write_inheritable_attribute :default_error_proc, error_proc_name
    end
  end

  @@field_error_procs = {
    :below_field => Proc.new do |html_tag, instance|
      if html_tag =~ /<label/
        %( <span class="field_with_error">
             #{html_tag}
           </span> )
      else
        %( <span class="field_with_error">
             #{html_tag}
             <span class="error_message">#{Array(instance.error_message).to_sentence}</span>
           </span> )
      end
    end
  }
  cattr_accessor :field_error_procs
  
  def render_with_error_proc(options = {}, *args, &block)
    with_error_proc(extract_error_proc_name(options)) do
      render_without_error_proc(options, *args, &block)
    end
  end
  alias_method_chain :render, :error_proc unless method_defined? :render_without_error_proc

  def extract_error_proc_name(options)
    error_proc_name = options.delete(:errors) if options.is_a? Hash
    error_proc_name ||= self.class.read_inheritable_attribute(:default_error_proc)
  end

  def with_error_proc(error_proc_name)
    if error_proc_name
      raise "invalid error_proc_name: #{error_proc_name}" unless self.field_error_procs[error_proc_name]
      old_proc = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = self.field_error_procs[error_proc_name]
      returning yield do
        ActionView::Base.field_error_proc = old_proc
      end
    else
      yield
    end
  end
  helper_method :with_error_proc
end
