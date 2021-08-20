# frozen_string_literal: true

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

  # @param [Spotlight::PageContent] content
  # @param [RegExp] regexp
  # @param [String] string
  def self.rewrite_content(content, regexp, string)
    content.map do |block|
      next block unless block.instance_of?(SirTrevorRails::Blocks::UploadedItemsBlock)

      gsub_urls(block, regexp, string)
    end
  end

  # @param [RegExp] regexp
  # @param [String] string
  def self.all(regexp, string)
    Spotlight::Page.all.each do |page|
      updated_content = rewrite_content(page.content, regexp, string)

      page.content = updated_content
      page.save
    end
  end
end
