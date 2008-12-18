module Admin::PhotosHelper
  def label_text_for_photo photo
    photo.new_record? ? 'Choose a photo' : 'Replace the photo'
  end
end