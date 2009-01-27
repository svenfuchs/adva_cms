// adva-cms default toolbar
FCKConfig.ToolbarSets['adva-cms'] = [
  ['Source','-','Save','Preview'],
  ['Cut','Copy','Paste','PasteText','PasteWord','-','Print'],
  ['Undo','Redo','-','Find','Replace','-','SelectAll'],
  '/',
  ['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript'],
  ['OrderedList','UnorderedList','-','Outdent','Indent','Blockquote'],
  ['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
  ['Link','Unlink','Anchor'],
  ['Table','Rule','SpecialChar'],
  ['TextColor','BGColor'],
  ['FitWindow','ShowBlocks']
];

// format the HTML output and source
FCKConfig.FormatOutput = true;
FCKConfig.FormatSource = true;

// ignore empty paragraphs
FCKConfig.IgnoreEmptyParagraphValue = true;

// don't process entities since we use UTF-8
FCKConfig.ProcessHTMLEntities = false;

// Enter triggers a new paragraph, Shift+Enter triggers line break (just like in most text processors)
FCKConfig.EnterMode = 'p';
FCKConfig.ShiftEnterMode = 'br';
