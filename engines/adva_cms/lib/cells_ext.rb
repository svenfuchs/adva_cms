module Cell
  class << self
    def all
      @all ||= begin
        require_all_cells
        Object.subclasses_of(BaseCell)
      end
    end

    private
    def require_all_cells
      # cell_files = Dir[RAILS_ROOT + '/app/cells/*.rb'] + Dir[File.join(RAILS_ROOT, 'vendor', 'adva', 'engines') + '/*/app/cells/*.rb'] +
      #   Dir[File.join(RAILS_ROOT, 'vendor', 'adva', 'plugins') + '/*/app/cells/*.rb']
      cell_files = Dir[RAILS_ROOT + '/app/cells/*.rb'] + Dir[File.join(RAILS_ROOT, 'vendor', 'plugins') + '/*/app/cells/*.rb']
      cell_files.each { |cell_file| require cell_file }
    end
  end
end