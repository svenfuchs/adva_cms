class RichViewComponent < Components::Base
  def urler
    render
  end

  def form
    render
  end

  def linker(url)
    @url = url
    render
  end
end