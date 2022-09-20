# frozen_string_literal: true

class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::DefaultComponentConfiguration

  # https://gitlab.com/surfliner/surfliner/issues/149
  CatalogController.blacklight_config.show.document_actions.delete(:sms)
  CatalogController.blacklight_config.show.document_actions.delete(:citation)

  CatalogController.blacklight_config.navbar.partials.delete(:saved_searches)
  CatalogController.blacklight_config.navbar.partials.delete(:search_history)

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm

    config.view.gallery(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.slideshow(document_component: Blacklight::Gallery::SlideshowComponent)

    config.show.partials = [
      :show_header,
      :show,
      :oembed,
      :media,
    ]

    # Default parameters to send to solr for all search-like
    # requests. See also SolrHelper#solr_search_params
    # config.default_solr_params = {
    #   qf: %w[
    #     full_title_tesim
    #     spotlight_upload_source_tesim
    #   ].join(" "),
    #   wt: "json",
    #   qt: "search",
    #   rows: 10,
    # }

    config.default_solr_params = {
      qt: "search",
      rows: 10,
      fl: "*",
    }

    config.document_solr_path = "get"
    config.document_unique_id_param = "ids"

    config.index.title_field = "full_title_tesim"

    # This one uses all the defaults set by the solr request
    # handler. Which solr request handler? The one set in
    # config[:default_solr_parameters][:qt], since we aren't
    # specifying it otherwise.
    config.add_search_field(
      "all_fields",
      label: I18n.t("spotlight.search.fields.search.all_fields")
    )
    config.add_sort_field(
      "relevance",
      sort: "score desc",
      label: I18n.t("spotlight.search.fields.sort.relevance")
    )

    config.add_field_configuration_to_solr_request!

    # https://github.com/projectblacklight/spotlight/issues/1812#issuecomment-327345318
    config.add_facet_fields_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
