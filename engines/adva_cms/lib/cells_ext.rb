module Cell
  class << self
    def all
      require_all_cells
      Object.subclasses_of(BaseCell)
    end

    private
    def require_all_cells
      Dir[File.join(RAILS_ROOT, 'vendor', 'adva', 'engines') + '/*/app/cells/*.rb'].each { |cell_file| require cell_file }
    end
  end
end