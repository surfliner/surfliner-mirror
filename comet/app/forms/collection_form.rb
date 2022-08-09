# frozen_string_literal: true

##
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class CollectionForm < Valkyrie::ChangeSet
  BannerInfoPrepopulator = lambda do |_options|
    self.banner_info ||= begin
      banner_info = CollectionBrandingInfo.where(collection_id: id.to_s, role: "banner")
      banner_file = File.split(banner_info.first.local_path).last unless banner_info.empty?
      alttext = banner_info.first.alt_text unless banner_info.empty?
      file_location = banner_info.first.local_path unless banner_info.empty?
      relative_path = "/" + banner_info.first.local_path.split("/")[-4..].join("/") unless banner_info.empty?
      {file: banner_file, full_path: file_location, relative_path: relative_path, alttext: alttext}
    end
  end

  LogoInfoPrepopulator = lambda do |_options|
    self.logo_info ||= begin
      logos_info = CollectionBrandingInfo.where(collection_id: id.to_s, role: "logo")

      logos_info.map do |logo_info|
        logo_file = File.split(logo_info.local_path).last
        relative_path = "/" + logo_info.local_path.split("/")[-4..].join("/")
        alttext = logo_info.alt_text
        linkurl = logo_info.target_url
        {file: logo_file, full_path: logo_info.local_path, relative_path: relative_path, alttext: alttext, linkurl: linkurl}
      end
    end
  end

  property :title, required: true
  property :depositor, required: true
  property :collection_type_gid, required: true

  property :human_readable_type, writable: false
  property :date_modified, readable: false
  property :date_uploaded, readable: false
  property :visibility, default: Hyrax::VisibilityIntention::PRIVATE

  property :member_of_collection_ids, default: [], type: Valkyrie::Types::Array

  property :banner_info, virtual: true, prepopulator: BannerInfoPrepopulator
  property :logo_info, virtual: true, prepopulator: LogoInfoPrepopulator

  class << self
    def model_class
      Hyrax::PcdmCollection
    end

    def primary_terms
      ["title"]
    end

    def secondary_terms
      []
    end
  end

  def thumbnail_id
    ""
  end

  def primary_terms
    self.class.primary_terms
  end

  def secondary_terms
    self.class.secondary_terms
  end

  def display_additional_fields?
    secondary_terms.any?
  end
end
