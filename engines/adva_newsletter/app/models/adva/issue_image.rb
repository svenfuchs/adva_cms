require "nokogiri"
require "open-uri"
require "addressable/uri"
require "tmail"

class Adva::IssueImage
  class WrongFileExtension < StandardError; end
  class NotAbsoluteUri     < StandardError; end
  class MissingImgElement  < StandardError; end
  class MissingImgFilename < StandardError; end

  class << self
    def parse(html)
      nodesets = image_nodesets_from(html)

      @issue_images = []
      nodesets.each do |nodeset|
        begin
          @issue_images << self.new(nodeset)
        rescue MissingImgElement, NotAbsoluteUri, MissingImgFilename, WrongFileExtension => error
          Rails.logger.debug error.message
        end
      end
      return @issue_images
    end
    alias [] parse
    
    def valid_extensions
      %w[png jpg gif]
    end

    private
      def image_nodesets_from(html)
        Nokogiri::HTML.parse(html).css("img")
      end
  end

  def initialize(fragment = "")
    @element = Nokogiri::HTML.fragment(fragment.to_s).at("img")
    raise MissingImgElement if @element.nil?
    raise MissingImgFilename if (uri.nil? && filename.nil?) 
    raise NotAbsoluteUri unless addressable.try(:absolute?)
    raise WrongFileExtension unless valid_extension?
  end
  
  def alt
    @element["alt"]
  end
  
  def uri
    addressable.try(:to_s)
  end

  def filename
    addressable.try(:basename)
  end
  
  def extension
    addressable.extname.sub(/^\./,"") unless addressable.nil?
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
    def addressable
      @addressable ||= Addressable::URI.parse(@element["src"]) unless @element["src"].nil?
    end
    
    def openuri
      begin
        @openuri ||= open(uri) unless uri.nil?
      rescue SocketError, OpenURI::HTTPError, Timeout::Error => error
        Rails.logger.debug error.message
      end
    end
end
