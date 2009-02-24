class ArticleFormBuilder < ExtensibleFormBuilder
  after(:article, :default_fields) do |f|
    <<-html
      <fieldset class="clearfix">
        <div class="col">
          #{ f.text_field(:meta_author, :label => true) }
          #{ f.text_field(:meta_geourl, :label => true) }
          #{ f.text_field(:meta_copyright, :label => true) }
        </div>

        <div class="col">
          #{ f.text_field(:meta_keywords, :label => true) }
          #{ f.text_area(:meta_description, :class => 'short', :label => true) }
        </div>
      </fieldset>
    html
  end
end