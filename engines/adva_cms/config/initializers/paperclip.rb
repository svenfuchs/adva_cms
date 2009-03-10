Paperclip.options[:command_path] = %x[which convert].chomp.gsub(/convert/, '')
