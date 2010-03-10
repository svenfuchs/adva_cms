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
          CKEDITOR.replace($(this).attr('name'));
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
