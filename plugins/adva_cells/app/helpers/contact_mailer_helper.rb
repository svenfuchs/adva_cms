module ContactMailerHelper
  def render_fields(fields)
    builder = ContactMailFormBuilder.new
    fields.each { |field| builder.add_field(field.symbolize_keys!) }
    builder.render_fields
  end
end
