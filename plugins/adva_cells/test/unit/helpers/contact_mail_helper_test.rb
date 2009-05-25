require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContactMailerHelperTest < ActionView::TestCase
  include ContactMailerHelper
  
  test "#render renders the correct html" do
    render_fields(fields_options).should == output_html
  end
   
  def fields_options
    { "fields" => 
       { "field"=> [ {"name"=>"subject", "type"=>"text_field"},
                     {"name"=>"body", "type"=>"text_area"},
                     {"checked"=>"true", "name"=>"check me", "type"=>"radio_button", "value"=>"100"},
                     {"checked"=>"true", "name"=>"check me", "type"=>"check_box", "value"=>"100"},
                     {"name"=>"rating", "options"=>
                                        {"option"=> [{"value"=>"1", "label"=>"Very good"}, 
                                                     {"value"=>"5", "label"=>"Very bad"}
                                        ]},
                      "type"=>"select"
                      }
                   ]
        }
    }
  end
  
  def output_html
    <<-HTML
<p>
	<label for='contact_mail_subject'>subject</label>
	<input id="contact_mail_subject" name="contact_mail[subject]" type="text" />
</p>
<p>
	<label for='contact_mail_body'>body</label>
	<textarea id="contact_mail_body" name="contact_mail[body]"></textarea>
</p>
<p>
	<label for='contact_mail_check_me'>check me</label>
	<input checked="checked" id="contact_mail_check_me_100" name="contact_mail[check_me]" type="radio" value="100" />
</p>
<p>
	<label for='contact_mail_check_me'>check me</label>
	<input checked="checked" id="contact_mail_check_me" name="contact_mail[check_me]" type="checkbox" value="100" />
</p>
<p>
	<label for='contact_mail_rating'>rating</label>
	<select id="contact_mail_rating" name="contact_mail[rating]"><option value="1">Very good</option>
<option value="5">Very bad</option></select>
</p>
    HTML
  end
end

# require 'rubygems'
# require 'active_support'
# 
# xml = %(
#   <h2>Heading 2</h2>
#   <div>
#     <p>Some text ...</p>
#   </div>
#   
#   <cell name="name/state">
#     <fields>
#       <field name="subject" type="text_field" />
#       <field name="check me" type="radio_button" checked="true" value='100'" />
#       <field name="check me" type="check_box" checked="true" value='100'" />
#       <field name="rating" type="select">
#         <options>
#           <option value="1" label="Very good" />
#           <option value="5" label="Very bad" />
#         </options>
#       </field>
#     </fields>
#   </cell>
# 
#   <div>
#     <p>Some more text ...</p>
#   </div>
# )
# 
# xml.scan(/(<cell[^>]*\/\s*>|<cell[^>]*>.*?<\/cell>)/m).each do |matches|
#   p Hash.from_xml(matches.first)
# end