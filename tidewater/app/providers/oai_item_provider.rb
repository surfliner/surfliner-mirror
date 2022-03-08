require "oai_item_wrapper"

class OaiItemProvider < OAI::Provider::Base
  repository_name ENV.fetch("OAI_REPOSITORY_NAME")
  repository_url "#{ENV.fetch("OAI_REPOSITORY_ORIGIN")}/oai"
  record_prefix "oai:#{ENV.fetch("OAI_NAMESPACE_IDENTIFIER")}"
  admin_email ENV.fetch("OAI_ADMIN_EMAIL")
  source_model Tidewater::OaiItemWrapper.new(OaiItem)
  sample_id ENV.fetch("OAI_SAMPLE_ID")
end
