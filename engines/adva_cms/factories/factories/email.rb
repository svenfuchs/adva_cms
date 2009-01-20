Factory.define :email do |e|
  e.from "admin@example.org"
  e.to   "user@example.org"
  e.mail "From: admin@example.orgg\r\nTo: user@example.org\r\nSubject: [example] Example header\r\nMime-Version: 1.0\r\nContent-Type: text/plain; charset=utf-8\r\n\r\neExample body\n"
end
