# frozen_string_literal: true

class PdfsController < ApplicationController
  # No layout
  layout false

  # Render the PDF inline from cloud storage
  def embed
    doc_id = params[:id]
    resource_upload_path = Spotlight::Resources::Upload.find(doc_id.to_s.split("-").last).upload.image.to_s

    data = URI.parse(resource_upload_path).open.read

    send_data(data,
      filename: "starlight-upload-#{doc_id}.pdf",
      type: "application/pdf",
      disposition: "inline")
  end
end
