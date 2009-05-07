class Test::Unit::TestCase
  share :a_contact_mail do
    before do
      @contact_mail = ContactMail.first
    end
  end
end