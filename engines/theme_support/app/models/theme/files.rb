require 'theme/path'
require 'theme/file'
require 'theme/asset'
require 'theme/other'
require 'theme/template'

class Theme
  class Files < Array
    attr_accessor :type, :theme

    def initialize(type, theme)
      @type = type
      @theme = theme
      pattern = "#{theme.path}/#{@type.filename_pattern}"
      push *Pathname.glob(pattern).select{|path| path.file? }
    end

    def push(*paths)
      super *paths.map!{|path| @type.new(theme, path) }.select{|file| file.valid? }
      sort
    end

    def find(id)
      ix = ids.index(id)
      self[ix] if ix
    end

    private

    def ids
      @ids = map(&:id)
    end
  end
end
