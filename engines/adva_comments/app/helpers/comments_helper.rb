module CommentsHelper
  def comments_feed_title(*owners)
    options = owners.extract_options!
    separator = options[:separator] || ' &raquo; '
    I18n.t(:'adva.titles.comments') + ': ' + owners.compact.uniq.map(&:title).join(separator)
  end

  methods = %w(admin_comments_path admin_comment_path
               new_admin_comment_path edit_admin_comment_path)

  methods.each do |method|
    delegate = method.sub('admin', 'admin_site')
    module_eval <<-CODE, __FILE__, __LINE__
      def #{method}(*args)
        options = args.extract_options!
        args.unshift(@site) unless args.first.is_a? Site
        merge_admin_comments_query_params(options)
        #{delegate} *(args << options).compact
      end
    CODE
  end

  def link_to_remote_comment_preview
    link_to_remote I18n.t(:'adva.titles.preview'),
      :url     => preview_comments_path,
      :with    => "Form.serialize($('comment_form'))",
      :update  => 'preview',
      :loading => "$('comment_preview_spinner').show();",
      :loaded  => "$('comment_preview_spinner').hide();"
  end

  def comment_form_hidden_fields(commentable)
    hidden_field_tag('return_to', request.request_uri) + "\n" +
    hidden_field_tag('comment[commentable_type]', commentable.class.name, :id => 'comment_commentable_type') + "\n" +
    hidden_field_tag('comment[commentable_id]', commentable.id, :id => 'comment_commentable_id') + "\n"
  end

  private

    # TODO obviously doesn't work as expected on the SectionsController where the
    # section_id is in params[:id]
    def merge_admin_comments_query_params(options)
      options.merge! params.slice(:section_id, :content_id).reject{|key, value| value.blank? }
      options.symbolize_keys!
      options.delete(:section_id) if options[:content_id]
    end
end