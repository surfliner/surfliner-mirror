# frozen_string_literal: true

require "rails_helper"

RSpec.describe Qa::SchemaController do
  let(:params) { {property: "rights_statement", availability: "generic_object"} }
  let(:authority) {
    Qa::Authorities::Schema.property_authority_for(
      name: params[:property],
      availability: params[:availability]
    )
  }

  it "#index" do
    get :index, params: params
    expect(response.body).to eq authority.all.to_json
  end

  it "#show" do
    get :show, params: {id: "my_statement"}.merge(params)
    expect(response.body).to eq authority.find(:my_statement).to_json
  end

  it "#search" do
    get :search, params: {q: "Rights State"}.merge(params)
    expect(response.body).to eq authority.search("Rights State").to_json
  end

  it "#fetch" do
    get :fetch, params: {uri: authority.find(:my_statement)[:uri]}.merge(params)
    expect(response.body).to eq authority.find(:my_statement).to_json
  end
end
