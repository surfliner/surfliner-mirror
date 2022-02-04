# Hyrax currently runs Blacklight 6.14, which includes a broken (and now
# removed) thumbnail_url helper method.  When trying to view a FileSet show
# page, the `document` below is a FileSetPresenter.  The `#has?` method for
# FileSetPresenter returns false if thumbnail_id_ssi is an empty string.  The
# original version of this thumbnail_url method had nothing outside the `if`,
# meaning that it returns nil when a field isn't indexed.  In the case of
# thumbnails, this means sending a nil to `image_tag`, which results in an
# unhandled error.  Until Hyrax upgrades its Blacklight, we can fix this method
# here by adding an `else` clause that returns the default image when the field
# is unavailable.
#
# @see https://github.com/projectblacklight/blacklight/commit/3f071891f9a7c8e901bb62f73d02da88461216b4#diff-2eeaaecc55dfca66639bc3e4ca9bc1da082d6037235b36225180da7f8ca736e1
ActiveSupport::Reloader.to_prepare do
  Blacklight::CatalogHelperBehavior.module_eval do
    def thumbnail_url document
      if document.has? blacklight_config.view_config(document_index_view_type).thumbnail_field
        document.first(blacklight_config.view_config(document_index_view_type).thumbnail_field)
      else
        ActionController::Base.helpers.image_path "default.png"
      end
    end
  end
end
