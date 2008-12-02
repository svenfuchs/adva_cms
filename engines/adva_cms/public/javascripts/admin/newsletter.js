var IssueForm = {
  saveDraft: function() {
		$F(this) ? $('delivery').hide() : $('delivery').show();
  }
}
Event.addBehavior({
  '#issue-draft':   function() { Event.observe(this, 'change', IssueForm.saveDraft.bind(this)); }
});
