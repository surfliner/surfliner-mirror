# frozen_string_literal: true

Rails.logger.debug { "Setting custom controller class variables for Hyrax" }
Hyrax::HomepageController.presenter_class = CometHomepagePresenter
