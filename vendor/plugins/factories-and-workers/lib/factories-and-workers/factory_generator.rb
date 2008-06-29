module Factory

  IGNORED_COLUMNS = %w[ id created_at updated_at created_on updated_on ]

  def self.generate_template arg
    model = arg.classify.constantize
    columns = {}
    model.columns.each do |col|
      key = col.name
      if key =~ /^(.+)_id$/
        columns[ $1.to_sym ]  = :belongs_to_model
      else
        columns[ key.to_sym ] = { :type => col.type, :default => col.default }
      end unless IGNORED_COLUMNS.include?( key )
    end

    template = "\nfactory :#{model.to_s.underscore}, {\n"
    columns.each_pair do |name, val|
      template += "  :#{name} => #{ default_for( val ) },\n"
    end
    template += "}\n\n"
  end

  protected

  def self.default_for val
    case val
    when :belongs_to_model
      return val.inspect
    when Hash
      # return val[:default] if val[:default] # not sure if this works?
      case val[:type]
      when :integer
        123
      when :string, :text
        "SomeString".inspect
      when :float
        1.23
      when :date
        "lambda{ 7.days.from_now }"
      when :datetime
        "lambda{ 12.hours.from_now }"
      when :boolean
        val[:default] || false
      end
    end
  end

end
