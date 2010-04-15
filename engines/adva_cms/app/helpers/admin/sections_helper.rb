module Admin::SectionsHelper

  def links_to_translations(content)
    return '' if content.new_record?
    block = Proc.new { |locale| link_to_edit(locale, content, :cl => locale) } unless block
    locales = content.translated_locales.map { |locale| block.call(locale.to_s) }
    content_tag :span, :class => "content_translations"  do
      t(:"adva.sections.links.translations", :locales => locales.join(', ')) +
      "<p class=\"hint\" for=\"content_translations\">#{t(:'adva.sections.hints.translation')}</p>"
    end
  end

  def localize_section_title(section, locale)
    translation = section.globalize_translations.find_by_locale(locale)
    translation.present? ? translation.title : section.title
  end

end
