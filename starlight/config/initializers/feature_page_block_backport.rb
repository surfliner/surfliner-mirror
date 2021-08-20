# frozen_string_literal: true

# backporting https://github.com/projectblacklight/spotlight/pull/2756
SirTrevorRails::Blocks::FeaturedPagesBlock.class_eval do
  def as_json(_options = nil)
    result = super
    result[:data][:item] ||= {}

    result[:data][:item].transform_values! do |v|
      begin
        v["thumbnail_image_url"] = parent.exhibit.pages.find(v["id"]).thumbnail_image_url
      rescue ActiveRecord::RecordNotFound
        v = nil
      end
      v
    end

    result[:data][:item].compact!
    result
  end
end
