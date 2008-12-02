Factory.define :message do |m|
  m.subject   'test message'
  m.body      'test message body'
  m.sender    { |m| m.association :johan_mcdoe }
  m.recipient { |m| m.association :don_macaroni }
end

Factory.define :reply, :class => Message do |m|
  m.subject   'Re: test message'
  m.body      'test reply body'
  m.parent_id { |m| m.association :message }
  m.sender    { |m| m.association :don_macaroni }
  m.recipient { |m| m.association :johan_mcdoe }
end