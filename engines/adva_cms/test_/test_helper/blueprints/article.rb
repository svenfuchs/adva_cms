Article.blueprint do
  title    { 'an article' }
  body     { 'an article body' }
  author   { User.make }
  tag_list { 'foo bar' }
end