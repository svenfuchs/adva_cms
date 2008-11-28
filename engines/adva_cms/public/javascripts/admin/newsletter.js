var NewsletterForm = {
  saveDraft: function() {
		$F(this) ? $('issue').hide() : $('issue').show();
  }
}
Event.addBehavior({
  '#newsletter-draft':   function() { Event.observe(this, 'change', NewsletterForm.saveDraft.bind(this)); }
});
