# frozen_string_literal: true

require "active_support"
require "delegate"
require "dry-validation"
require "iso-639"
require "valkyrie"
require "yaml"

module SurflinerSchema
  require "surfliner_schema/contract"
  require "surfliner_schema/controlled_value"
  require "surfliner_schema/controlled_values"
  require "surfliner_schema/division"
  require "surfliner_schema/form_definition"
  require "surfliner_schema/form_fields"
  require "surfliner_schema/grouping"
  require "surfliner_schema/loader"
  require "surfliner_schema/mapping"
  require "surfliner_schema/mappings"
  require "surfliner_schema/property"
  require "surfliner_schema/profile"
  require "surfliner_schema/reader"
  require "surfliner_schema/resource"
  require "surfliner_schema/resource_class"
  require "surfliner_schema/schema"
  require "surfliner_schema/section"
  require "surfliner_schema/version"
end
