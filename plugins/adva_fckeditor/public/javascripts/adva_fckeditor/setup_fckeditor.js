applyOrRemoveFCKeditors = function() {
  $('textarea.wysiwyg').each(function() {
    id = $(this).attr('id');
    filter = $('select.columnsFilter');

    // transform all textareas to FCKeditors, but only if filter is set to plain HTML
    if(filter && $(filter).val() == '') {
      // some calculations
      height = $(this).height();
      if(height == 0) height = 200; // default height = 200px

      // initialize FCKeditor
      FCKeditor.BasePath = '/javascripts/adva_fckeditor/fckeditor/';
      var oFCKeditor = new FCKeditor(id, '100%', height, 'adva-cms');
      oFCKeditor.Config['CustomConfigurationsPath'] = '/javascripts/adva_fckeditor/config.js';
      oFCKeditor.ReplaceTextarea();
    } else {
      f = $('#' + id + '___Frame');
      c = $('#' + id + '___Config');
      if(f) f.remove();
      if(c) c.remove();
      $(this).show();
    }
  });
}

$(document).ready(function() {
  applyOrRemoveFCKeditors();
  $('select.columnsFilter').change(function() {
    applyOrRemoveFCKeditors();
  });
})