applyOrRemoveFCKeditors = function() {
  filter = $$('select.columnsFilter').first();

  // transform all textareas to FCKeditors, but only if filter is set to plain HTML
  if(filter && $F(filter) == '') {
    // by default, apply FCKeditor to all textareas
    $$('textarea.wysiwyg').each(function(t) {
      // some calculations
      height = t.getDimensions()['height'];
      if(height == 0) height = 200; // default height = 200px

      // initialize FCKeditor
      FCKeditor.BasePath = '/javascripts/adva_fckeditor/fckeditor/';
      var oFCKeditor = new FCKeditor(t.id, '100%', height, 'adva-cms');
      oFCKeditor.Config['CustomConfigurationsPath'] = '/javascripts/adva_fckeditor/config.js';
      oFCKeditor.ReplaceTextarea();
    });
  } else {
    // otherwise remove instances
    $$('textarea.wysiwyg').each(function(t) {
      f = $(t.id + '___Frame');
      c = $(t.id + '___Config');
      if(f) f.remove();
      if(c) c.remove();
      $(t).show();
    });
  }
}

Event.onReady(function() {
  applyOrRemoveFCKeditors();
});

Event.addBehavior({
  'select.columnsFilter:change':function(e) {
    applyOrRemoveFCKeditors();
  }
});