Factory.define :message do |m|
  m.subject   'test message'
  m.body      'test message body'
  m.sender    { |m| m.association :johan_mcdoe }
  m.recipient { |m| m.association :don_macaroni }
end