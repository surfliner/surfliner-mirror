class ItemController < ApplicationController
  def index
    source_iri = params.fetch(:source_iri)

    oai_item = OaiItem.find_by(source_iri: source_iri)

    raise ActiveRecord::RecordNotFound.new if oai_item.nil?

    redirect_to oai_path(verb: "GetRecord", identifier: "oai:#{ENV.fetch("OAI_NAMESPACE_IDENTIFIER")}:#{oai_item.id}", metadataPrefix: "oai_dc")
  rescue ActionController::ParameterMissing
    raise ActionController::BadRequest.new, "Parameter source_iri is missing."
  end
end
