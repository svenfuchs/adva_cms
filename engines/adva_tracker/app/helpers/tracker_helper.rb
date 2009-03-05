module TrackerHelper
  def parent_id
    new_path? ? parent_url[-3] : parent_url[-2]
  end
  
  def parent_type
    model_type = new_path? ? parent_url[-4] : parent_url[-3]
    model_type.singularize.capitalize
  end
  
private
  def parent_url
    request.url.split("/")
  end
  
  def new_path?
    ["new","edit"].include? parent_url.last
  end
end
