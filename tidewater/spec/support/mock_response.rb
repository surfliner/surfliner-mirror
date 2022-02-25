# frozen_string_literal: true

# Mock net/http get responce
def mock_response(url)
  uri = URI(resource_uri)
  req = Net::HTTP::Get.new(uri)
  req["Accept"] = "application/json"
  req["HTTP_ACCEPT"] = "application/ld+json;profile=#{ENV.fetch("OAI_METADATA_PROFILE", "tag:surfliner.github.io,2022:api/oai_dc")}"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(req) }
end
