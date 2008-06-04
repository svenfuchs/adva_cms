module CommentsHelper  
  def comments_feed_title
    'Comments: ' + [@site, @section, @commentable].uniq.map(&:title).join(' » ')
  end
    
  def comment_expiration_options
    [['Are not allowed', -1],
     ['Never expire', 0], 
     ['Expire 24 hours after publishing',     1],
     ['Expire 1 week after publishing',       7],
     ['Expire 1 month after publishing',      30],
     ['Expire 3 months after publishing',     90]]
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
  
  def link_to_comments_owner
    if @content
      path = send :"edit_admin_#{@content.class.name.downcase}_path", @site, @section, @content
      link_to @content.title, path
    elsif @section
      link_to @section.title, admin_section_path_for(@section)
    else
      link_to @site.name, admin_site_path(@site)
    end
  end
  
  def link_to_remote_comment_preview
    link_to_remote "Preview",
      :url     => preview_comments_path,
      :with    => "Form.serialize($('comment_form'))",
      :update  => 'preview',
      :loading => "$('comment-preview-spinner').show();",
      :loaded  => "$('comment-preview-spinner').hide();"
  end
  
  def comment_form_hidden_fields(commentable)
    hidden_field_tag('redirect_to', request.request_uri) + "\n" +
    hidden_field_tag('commentable[type]', commentable.class.name, :id => 'commentable_type') + "\n" +
    hidden_field_tag('commentable[id]', commentable.id, :id => 'commentable_id') + "\n"
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