class ComponentGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.class_collisions "#{class_name}Component"
      m.directory "app/components/#{file_name}"
      m.template "component_template.rb", "app/components/#{file_name}_component.rb"

      actions.each do |action|
        m.template "view_template.rb", "app/components/#{file_name}/#{action}.erb"
      end
    end
  end
end