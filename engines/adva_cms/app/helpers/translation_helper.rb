module TranslationHelper
  def links_to_translations(object, locale_key = object.class.name.demodulize.tableize, &block)
    return '' if object.new_record?
    block = Proc.new { |locale| link_to_edit(locale, object, :cl => locale, :id => "#{locale_key}_#{locale}") } unless block
    locales = object.translated_locales.map { |locale| block.call(locale.to_s) }
    content_tag(:span, :class => 'content_translations') do
      t(:"adva.links.available_translations", :locales => locales.join(', ')) +
      "<p class=\"hint\" for=\"content_translations\">#{t(:"adva.#{locale_key}.hints.translations")}</p>"
    end
  end

  def localize_object_attribute(object, attribute, locale)
    translation = object.globalize_translations.find_by_locale(locale)
    translation.present? ? translation.send(attribute) : object.send(attribute)
  end
end
