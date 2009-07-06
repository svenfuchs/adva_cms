require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTest
  class ArticleWithContactMailerTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @page = @site.sections.root
      @contact_mailer = @page.articles.build(:title => 'contact mailer',
                                             :body => contact_mailer_cell,
                                             :author => User.first,
                                             :published_at => Time.now - 1.month)
      @contact_mailer.save
    end
    
    test "article displays the contact mailer cell" do
      login_as_user
      
      # We have an article with contact mailer
      assert_equal contact_mailer_cell, @contact_mailer.body
      
      visit_contact_mailer_article
      article_displays_contact_mailer
    end
    
    test "article displays the contact mailer cell - even after put through fckeditor" do
      login_as_user
      
      # Edited by fckeditor
      @contact_mailer.update_attribute(:body, contact_mailer_cell_after_fckeditor)
      
      # We have an article with contact mailer
      assert_equal contact_mailer_cell_after_fckeditor, @contact_mailer.body
      
      visit_contact_mailer_article
    end
    
    def visit_contact_mailer_article
      visit page_article_path(@page, @contact_mailer.permalink)
      assert_template 'articles/show'
    end
    
    def article_displays_contact_mailer
      assert_select("form[action=?]", contact_mails_path(:return_to => '/articles/contact-mailer')) do
        assert_select "input[name=?]", "contact_mail[recipients]"
        assert_select "input[name=?]", "contact_mail[subject]"
        assert_select "textarea[name=?]", "contact_mail[body]"
        assert_select "input[name=?][checked=?]", "contact_mail[radio_button]", "checked"
        assert_select "input[name=?][checked=?]", "contact_mail[check_box]", "checked"
        assert_select "select[name=?]", "contact_mail[rating]"
      end
    end
    
    def contact_mailer_cell
      <<-XML
        <cell name="contact_mailer/mailer_form" recipients="first@email.com, second@email.com">
          <fields>
             <field name="subject" label="Subject" type="text_field" value="default subject" />
             <field name="body" label="Body" type="text_area" />
             <field name="radio button" label="Radio button" type="radio_button" checked="true" value='100' />
             <field name="check box" label="Checkbox" type="check_box" checked="true" value='100' />
             <field name="rating" label="Rate us!" type="select">
               <options>
                 <option value="1" label="Good" />
                 <option value="2" label="Bad" />
               </options>
             </field>
           </fields>
         </cell>
      XML
    end
    
    def contact_mailer_cell_after_fckeditor
      <<-XML
      <cell name="contact_mailer/mailer_form" recipients="first@email.com, second@email.com">   <fields>     <field name="subject" label="Subject" type="text_field" value="default subject"></field>     <field name="body" label="Body" type="text_area"></field>     <field name="radio button" label="Radio button" type="radio_button" checked="true" value="100"></field>     <field name="check box" label="Checkbox" type="check_box" checked="true" value="100"></field>     <field name="rating" label="Rate us!" type="select">
<options>                         </options>
</field>   </fields> </cell>
      XML
    end
  end
end