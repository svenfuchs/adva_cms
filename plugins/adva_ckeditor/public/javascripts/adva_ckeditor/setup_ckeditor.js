applyOrRemoveFCKeditors = function() {

  $('textarea.wysiwyg').each(function() {
    
    $.each(CKEDITOR.instances, function () {
      CKEDITOR.remove(this);
    });

    filter = $('select.columnsFilter')[0];
    
    // transform all textareas to FCKeditors, but only if filter is set to plain HTML or no filter is defined
    if(typeof filter == 'undefined' || $(filter).val() == '') {
      
      if($(this).hasClass('small')) {
        CKEDITOR.replace($(this).attr('name'), {
          toolbar : 'Basic'
        });
      } else {
          url_match = /(.*)\/sites\/(\d+)\/(.*)/i.exec(window.location.href);
          site_id = url_match[2];
          CKEDITOR.replace($(this).attr('name'), {
            // filebrowserBrowseUrl : '/javascripts/adva_ckeditor/ckfinder/ckfinder.html',
            // filebrowserImageBrowseUrl : '/javascripts/adva_ckeditor/ckfinder/ckfinder.html?type=Images',
            filebrowserImageUploadUrl : '/admin/sites/' + site_id + '/assets',
            filebrowserImageBrowseUrl : '/admin/sites/' + site_id + '/assets'
            //filebrowserBrowseUrl : '/admin/sites/' + site_id + '/assets'
            //filebrowserBrowseUrl : '/admin/sites/' + site_id + '/assets'
          });
      }
    } else {
        cke = $('#cke_' + $(this).attr('id'));
        if(cke) cke.remove();
        $(this).show();
        $(this).css('visibility', '');
    }
  });
}

$(document).ready(function() {
  applyOrRemoveFCKeditors();
  $('select.columnsFilter').change(function() {
    applyOrRemoveFCKeditors();
  });
});
