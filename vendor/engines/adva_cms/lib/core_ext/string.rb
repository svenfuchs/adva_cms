
class String
  # taken from permalink_fu
  # http://svn.techno-weenie.net/projects/plugins/permalink_fu
  def to_permalink
    s = Iconv.iconv('ascii//translit', 'utf-8', self).to_s
    s.gsub!(/\W+/, ' ') # all non-word chars to spaces
    s.strip!            # ohh la la
    s.downcase!         #
    s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
    s
  end

  # different implementation of #to_permalink to fix issues raised in
  # http://artweb-design.lighthouseapp.com/projects/13992/tickets/52-umlauts-in-permalinks
  # TODO: different rules in other languages? base it on CLDR?
  # def to_permalink
  #   s = self.dup
  # 
  #   replacements = { 
  #     # replacement         special character(s) to be replaced
  #     "A" =>                [ "À", "Á", "Â", "Ã", "Å"],
  #     "Ae" =>               [ "Ä", "Æ" ],
  #     "C" =>                [ "Ç" ],
  #     "D" =>                [ "Ð" ],
  #     "E" =>                [ "È", "É", "Ê", "Ë" ],
  #     "I" =>                [ "Ì", "Í", "Î", "Ï" ],
  #     "N" =>                [ "Ñ" ],
  #     "O" =>                [ "Ò", "Ó", "Ô", "Õ", "Ø" ],
  #     "Oe" =>               [ "Ö" ],
  #     "U" =>                [ "Ù", "Ú", "Û" ],
  #     "Ue" =>               [ "Ü" ],
  #     "Y" =>                [ "Ý" ],
  # 
  #     "p" =>                [ "Þ"],
  #     "a" =>                [ "à", "á", "â", "ã", "å" ],
  #     "ae" =>               [ "ä", "æ" ],
  #     "c" =>                [ "ç" ],
  #     "d" =>                [ "ð" ],
  #     "e" =>                [ "è", "é", "ê", "ë" ],
  #     "i" =>                [ "ì", "í", "î", "ï" ],
  #     "n" =>                [ "ñ" ],
  #     "o" =>                [ "ò", "ó", "ô", "õ", "ø" ],
  #     "oe" =>               [ "ö" ],
  #     "ss" =>               [ "ß" ],
  #     "u" =>                [ "ù", "ú", "û" ],
  #     "ue" =>               [ "ü" ],
  #     "y" =>                [ "ý" ]
  #   }
  # 
  #   replacements.each_pair do |replacement, search_chars|
  #     search_chars.each do |ch|
  #       s.gsub!(ch, replacement)
  #     end
  #   end
  # 
  #   s.gsub!(/[\'´`]/, '') # remove '
  #   s.gsub!(/([^\-\.A-Za-z0-9_])/, "-") # replace all special chars with hyphens
  #   s.gsub!(/([\-.][\-.]+)/, "-") # replace multiple hyphens with single hyphen
  #   s.gsub!(/(^[\-.]|[\-.]$)/, "") # remove leading and trailing hyphen
  # 
  #   s
  # end

  # def diff_to(other, format = :unified, context_lines = 3)
  #   data_self = self.split(/\n/).map! { |e| e.chomp }
  #   data_other = data_other.split(/\n/).map! { |e| e.chomp }
  #
  #   output = ""
  #   diffs = Diff::LCS.diff(data_other, data_self)
  #   return output if diffs.empty?
  #   oldhunk = hunk = nil
  #   file_length_difference = 0
  #   diffs.each do |piece|
  #     begin
  #       hunk = Diff::LCS::Hunk.new(data_other, data_self, piece, context_lines,
  #                                  file_length_difference)
  #       file_length_difference = hunk.file_length_difference
  #       next unless oldhunk
  #
  #       # Hunks may overlap, which is why we need to be careful when our
  #       # diff includes lines of context. Otherwise, we might print
  #       # redundant lines.
  #       if (context_lines > 0) and hunk.overlaps?(oldhunk)
  #          hunk.unshift(oldhunk)
  #       else
  #         output << oldhunk.diff(format)
  #       end
  #     ensure
  #       oldhunk = hunk
  #       output << "\n"
  #     end
  #   end
  #
  #   #Handle the last remaining hunk
  #   output << oldhunk.diff(format) << "\n"
  # end
end
