module MetaTagsHelper
  def meta_tags(resource)
    %w(author geourl copyright keywords description).map do |name|
      meta_tag name, resource.send(:"meta_#{name}") if resource.respond_to?(:"meta_#{name}")
    end.join("\n")
  end

  def meta_tag(name, content)
    tag 'meta', :name => name, :content => content
  end
end
