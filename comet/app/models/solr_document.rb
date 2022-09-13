# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  # override
  # https://github.com/samvera/hyrax/blob/main/app/models/concerns/hyrax/solr_document_behavior.rb#L50
  # since ActiveFedoraDummyModel doesn't return the correct Valkyrized GID with
  # #to_global_id
  def to_model
    @model ||= Hyrax.query_service.find_by(id: id)
  rescue Valkyrie::Persistence::ObjectNotFoundError => err
    Hyrax.logger.error "Failed to convert SolrDocument to object for #{id}; #{err.message}"
    raise err
  end
end
