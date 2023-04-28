module Qa
  ##
  # Controller for QA authorities defined by the schema.
  class SchemaController < Qa::TermsController
    skip_before_action :check_vocab_param

    ##
    # Define the authority for the controller as the appropriate
    # +Qa::Authorities::Schema::BasePropertyAuthority+ subclass.
    #
    # Expects an +:availability+ and +:property+ to have been defined via the
    # path.
    def init_authority
      @authority = Qa::Authorities::Schema.property_authority_for(
        name: params[:property],
        availability: params[:availability]
      )
    rescue Qa::InvalidSubAuthority, Qa::MissingSubAuthority => e
      msg = e.message
      logger.warn msg
      render json: {errors: msg}, status: :bad_request
    end
  end
end
