# frozen_string_literal: true

# See https://github.com/samvera/hyrax/blob/main/app/services/hyrax/collections/nested_collection_query_service.rb for more info

Hyrax::Collections::NestedCollectionQueryService.class_eval do
  # @api private
  #
  # Get the child collection's nesting depth
  #
  # @param child [::Collection]
  # @return [Fixnum] the largest number of collections in a path nested
  #   under this collection (including this collection)
  def self.child_nesting_depth(child:, scope:)
    return 1 unless child
    # The nesting depth of a child collection is found by finding the largest nesting depth
    # among all collections and works which have the child collection in the paths, and
    # subtracting the nesting depth of the child collection itself.
    # => 1) First we find all the collections with this child in the path, sort the results in descending order, and take the first result.
    # note: We need to include works in this search. They are included in the depth validations in
    # the indexer, so we do NOT use collection search builder here.
    builder = Hyrax::SearchBuilder.new(scope).with({q: "#{Samvera::NestingIndexer.configuration.solr_field_name_for_storing_pathnames}:/.*#{child.id}.*/",
                                                    sort: "#{Samvera::NestingIndexer.configuration.solr_field_name_for_deepest_nested_depth} desc"})
    builder.rows = 1
    query = clean_lucene_error(builder: builder)
    response = scope.repository.search(query).documents.first
    # Now we have the largest nesting depth for all paths containing this collection
    descendant_depth = response.nil? ? 0 : response[Samvera::NestingIndexer.configuration.solr_field_name_for_deepest_nested_depth]

    # => 2) Then we get the stored depth of the child collection itself to eliminate the collections above this one from our count, and add 1 to add back in this collection itself
    depth = Hyrax::Collections::NestedCollectionQueryService::NestingAttributes.new(id: child.id.to_s, scope: scope).depth
    child_depth = depth.nil? ? 0 : depth
    nesting_depth = descendant_depth - child_depth + 1

    # this should always be positive, but just being safe
    nesting_depth.positive? ? nesting_depth : 1
  end

  # @api private
  #
  # Get the parent collection's nesting depth
  #
  # @param parent [::Collection]
  # @return [Fixnum] the largest number of collections above
  #   this collection (includes this collection)
  def self.parent_nesting_depth(parent:, scope:)
    return 1 if parent.nil?
    parent_depth = Hyrax::Collections::NestedCollectionQueryService::NestingAttributes.new(id: parent.id.to_s, scope: scope).depth
    parent_depth.nil? ? 0 : parent_depth
  end
end
