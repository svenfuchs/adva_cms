class <%= class_name %>Component < Components::Base
  <% actions.each do |action| %>
  def <%= action %>
    render
  end
  <% end %>
end