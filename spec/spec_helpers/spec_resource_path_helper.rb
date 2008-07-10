module ResourcePathHelper  
  def set_resource_paths(resource, path_prefix, name_prefix = '')
    member = instance_variable_get :"@#{resource}"
    paths = { "#{name_prefix}collection_path" => resource_collection_path(path_prefix, resource),
              "#{name_prefix}member_path" => resource_member_path(path_prefix, resource, member),
              "#{name_prefix}new_member_path" => resource_collection_path(path_prefix, resource, :new),
              "#{name_prefix}edit_member_path" => resource_member_path(path_prefix, resource, member, :edit) }
    paths.each do |name, value|
      instance_variable_set :"@#{name}", value
    end
  end
  
  def resource_collection_path(path_prefix, name, action = nil)
    "#{path_prefix}#{name.to_s.pluralize}" + (action ? "/#{action}" : '')
  end
  
  def resource_member_path(path_prefix, name, member, action = nil)
    "#{resource_collection_path(path_prefix, name)}/#{member.to_param}" + (action ? "/#{action}" : '')
  end  
end