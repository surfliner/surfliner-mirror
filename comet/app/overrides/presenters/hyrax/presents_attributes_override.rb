Hyrax::PresentsAttributes.module_eval do
  ##
  # Injects a published_badge method into the +PresentsAttributes+ module
  # This module in included in Collection, FileSet, and Work presenters allowing us to display a publication status
  # badge in those views.
  def published_badge
    CometPublishedBadge.new(solr_document[:id]).render
  end
end
