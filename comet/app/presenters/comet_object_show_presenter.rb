# frozen_string_literal: true

class CometObjectShowPresenter < Hyrax::WorkShowPresenter
  private

  ##
  # Override {Hyrax::MemberPresenterFactory}, which relies on list_source.
  def member_presenter_factory
    @member_presenter_factory ||=
      Hyrax::PcdmMemberPresenterFactory.new(solr_document, current_ability)
  end
end
