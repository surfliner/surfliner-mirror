# frozen_string_literal: true

module TrevorURL
  # @param [SirTrevorRails::Blocks::UploadedItemsBlock] block
  # @param [RegExp] regexp
  # @param [String] string
  def self.gsub_urls(block, regexp, string)
    block.item.each_value do |v|
      v["url"] = v["url"].gsub(regexp, string)
    end
    block
  end

  # @param [RegExp] regexp
  # @param [String] string
  def self.all(regexp, string)
    Spotlight::FeaturePage.all.each do |page|
      page.content = rewrite_content(page.content, regexp, string)
      page.save
    end
  end

  # @param [Spotlight::PageContent] content
  # @param [RegExp] regexp
  # @param [String] string
  def self.rewrite_content(content, regexp, string)
    content.map do |block|
      next block unless block.instance_of?(SirTrevorRails::Blocks::UploadedItemsBlock)

      gsub_urls(block, regexp, string)
    end
  end
end
