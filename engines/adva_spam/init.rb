require File.expand_path(File.dirname(__FILE__) + '/lib/spam_engine/filter')

SpamEngine::Filter.register_default(SpamEngine::Filter::Default)
SpamEngine::Filter.register_default(SpamEngine::Filter::Akismet)
SpamEngine::Filter.register_default(SpamEngine::Filter::Defensio)