# frozen_string_literal: true

Geoserver::Publish::DataStore.class_eval do
  def upload(workspace_name:, data_store_name:, file:)
    content_type = 'application/zip'
    path = upload_url(workspace: workspace_name, data_store: data_store_name)
    connection.put(path: path, payload: file, content_type: content_type)
  end

  private

  def upload_url(workspace:, data_store:)
    "workspaces/#{workspace}/datastores/#{data_store}/file.shp"
  end
end
