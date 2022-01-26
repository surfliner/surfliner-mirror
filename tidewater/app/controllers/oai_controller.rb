class OaiController < ApplicationController
  def index
    provider = OaiItemProvider.new
    response = provider.process_request(oai_params.to_h)
    render body: response, content_type: "text/xml"
  end

  private

  def oai_params
    params.permit(:verb, :identifier, :metadata_prefix, :set, :from, :until, :resumptionToken)
  end
end
