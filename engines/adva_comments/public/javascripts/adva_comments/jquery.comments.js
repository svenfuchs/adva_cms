var Comment = {
  preview: function(event) {
    event.preventDefault();
    $.ajax({
      url: this.href,
      type: 'post',
      dataType: 'html',
      data: $('form#comment_form').serializeArray(),
      success: function(data, status) {
        $('#preview').html(data);
      },
      beforeSend: function(xhr) {
        $('#comment_preview_spinner').show();
      },
      complete: function(xhr, status) {
        $('#comment_preview_spinner').hide();
      }
    });
  }
}

$(document).ready(function() {
  $('a#preview_comment').show();
  $('a#preview_comment').click(Comment.preview);
});
