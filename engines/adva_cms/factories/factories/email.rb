Factory.define :email do |e|
  e.from "admin@example.org"
  e.to   "user@example.org"
  e.mail "add valid email here"
end
