# frozen_string_literal: true

##
# Utilities for managing SirTrevorRails content blocks
module TrevorURL
  # @param [SirTrevorRails::Blocks::UploadedItemsBlock] block
  # @param [RegExp] regexp
  # @param [String] string
  def self.gsub_urls(block, regexp, string)
    block.item&.each_value do |v|
      v["url"] = v["url"].gsub(regexp, string)
    end
    block
  end

  ##
  # @param [Spotlight::PageContent] content
  # @param [RegExp] regexp
  # @param [String] string
  def self.rewrite_content(content, regexp, string)
    content.map do |block|
      next block unless block.instance_of?(SirTrevorRails::Blocks::UploadedItemsBlock)

      gsub_urls(block, regexp, string)
    end
  end

  ##
  # Batch update all content blocks matching a given regular expression,
  # replacing with the given string.
  #
  # @param [RegExp] regexp
  # @param [String] string
  def self.rewrite_all(regexp, string)
    Spotlight::Page.all.each do |page|
      updated_content = rewrite_content(page.content, regexp, string)
      begin
        page.content = updated_content
        page.save
      rescue => err
        # don't stop processing content blocks if one fails
        Rails.logger.error "Failed to rewrite URLs in #{page}\n#{err.message}"
      end
    end
  end
end
