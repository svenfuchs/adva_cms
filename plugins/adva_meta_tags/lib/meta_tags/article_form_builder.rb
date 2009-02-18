class ArticleFormBuilder < ExtensibleFormBuilder
  after(:article, :default_fields) do |f|
    <<-html
      <fieldset class="clearfix">
        <div class="col">
          #{ f.label(:meta_author) }
          #{ f.text_field(:meta_author) }

          #{ f.label(:meta_geourl) }
          #{ f.text_field(:meta_geourl) }

          #{ f.label(:meta_copyright) }
          #{ f.text_field(:meta_copyright) }
        </div>

        <div class="col">
          #{ f.label(:meta_keywords) }
          #{ f.text_field(:meta_keywords) }

          #{ f.label(:meta_description) }
          #{ f.text_area(:meta_description, :class => 'short') }
        </div>
      </fieldset>
    html
  end
end