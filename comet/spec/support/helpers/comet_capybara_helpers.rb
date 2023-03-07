module CometCapybaraHelpers
  def visit(*)
    super
  rescue TypeError => err
    Hyrax.logger.error("Trying to rescue from #visit failure: #{err}")
    super
  end
end
