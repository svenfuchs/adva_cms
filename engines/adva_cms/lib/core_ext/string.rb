class String
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
