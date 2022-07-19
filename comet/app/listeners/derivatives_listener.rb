# frozen_string_literal: true

##
# An event listener for triggering derivative generation.
class DerivativesListener
  ##
  # Run derivatives when the file has been characterized if
  # appropriate.
  def on_file_characterized(event)
    metadata = event[:file_metadata]

    unless metadata&.original_file? # do nothing unless this is an :original_file
      Hyrax.logger.debug("Not generating derivatines for file with ID: " \
                         "#{metadata.file_identifier}.\n\t" \
                         "It's not an OriginalFile; types: #{metadata.type}.")
      return
    end

    Hyrax.logger.debug("Generating derivatines for file with ID: " \
                       "#{metadata.file_identifier}.\n\t" \
                       "And types: #{metadata.type}.")

    ValkyrieCreateDerivativesJob
      .perform_later(event[:file_set_id].to_s, event[:file_id].to_s)
  end
end
