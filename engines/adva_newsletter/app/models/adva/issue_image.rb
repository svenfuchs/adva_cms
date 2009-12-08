require "open-uri"
require "uri"
require "pathname"
require "tmail"

class Adva::IssueImage
  class NotAbsoluteUri            < StandardError; end
  class MissingValidImageElement  < StandardError; end
  class MissingImageFilename      < StandardError; end
  class WrongImageExtension       < StandardError; end

  class << self
    def parse(html)
      @issue_images = []
      image_elements = find_images(html)

      image_elements.each do |image_element|
        begin
          @issue_images << self.new(image_element)
        rescue MissingValidImageElement, NotAbsoluteUri, MissingImageFilename, WrongImageExtension => error
          Rails.logger.debug error.message
        end
      end
      return @issue_images
    end
    alias [] parse

    def valid_extensions
      %w[png jpg gif]
    end

    def find_images(html)
      images = html.scan(/(<img [^<]*>)/).flatten.uniq
      images.map do |img|
        {
          :src => attribute_value( img, :src ),
          :alt => attribute_value( img, :alt ),
        }
      end
    end

    protected

    def attribute_value(html, attribute)
      html.scan(/#{attribute}=["']([^'"]*)["']/).flatten.first
    end
  end

  def initialize(element = "")
    @image_element = element.kind_of?(String) ? Adva::IssueImage.find_images(element).first : element
    raise MissingValidImageElement if (@image_element.nil?  || @image_element[:src].nil?)
    # || !@image_element.elem?
    @uri = URI.parse(@image_element[:src])
    raise NotAbsoluteUri if (uri.blank? || !@uri.absolute?)

    @pathname = Pathname.new(@uri.path)
    raise MissingImageFilename if filename.blank?
    raise WrongImageExtension unless valid_extension?
  end

  def alt
    @image_element[:alt]
  end

  def uri
    @uri.to_s
  end

  def filename
    @pathname.basename.to_s
  end

  def extension
    @pathname.basename.extname.sub(/^\./,"") if filename.present?
    # addressable.extname.sub(/^\./,"") unless addressable.nil?
  end
  
  def valid_extension?
    Adva::IssueImage.valid_extensions.include?(extension.downcase)
  end

  def file
    openuri.try(:read)
  end
  
  def content_type
    openuri.try(:content_type)
  end
  
  def cid
    @cid ||= TMail.new_message_id
  end
  
  def cid_plain
    cid.gsub(/[<>]/,"")
  end
  
  private
    def openuri
      begin
        @openuri ||= open(uri) unless uri.nil?
      rescue SocketError, OpenURI::HTTPError, Timeout::Error => error
        Rails.logger.debug error.message
      end
    end
end
