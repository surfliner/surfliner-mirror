module ParserExportRecordSetOverride
  # @override count works only in comet
  # @return [Integer]
  def count
    sum = works.count
    return sum if limit.zero?
    return limit if sum > limit
    sum
  end

  # @override Yield works only for comet.  Once we've yielded as many times
  # as the parser's limit, we break the iteration and return.
  #
  # @yieldparam id [String] The ID of the work/collection/file_set
  # @yieldparam entry_class [Class] The parser associated entry class for the
  #             work/collection/file_set.
  #
  # @note The order of what we yield has been previously determined.
  def each
    counter = 0

    works.each do |work|
      break if limit_reached?(limit, counter)
      yield(work.fetch("id"), work_entry_class)
      counter += 1
    end
  end

  private

  def works_query_kwargs
    query_kwargs
  end

  # @override use the class name for fileset to avoid solr query error
  # @note Specifically not memoizing this so we can merge values without changing the object.
  #
  # No sense attempting to query for more than the limit.
  def query_kwargs
    {fl: "id,#{Bulkrax.file_model_class.name.demodulize.underscore}_ids_ssim", method: :post, rows: row_limit}
  end
end

Bulkrax::ParserExportRecordSet::Base.prepend ParserExportRecordSetOverride
