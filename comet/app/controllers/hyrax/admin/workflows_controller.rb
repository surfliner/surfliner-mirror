# frozen_string_literal: true

##
# This will override the default Hyrax::Admin::WorkflowsController
# to support reviewing submissions in batch
module Hyrax
  # Presents a list of works in workflow
  class Admin::WorkflowsController < ApplicationController
    before_action :ensure_authorized!
    with_themed_layout "dashboard"
    class_attribute :deposited_workflow_state_name

    # Works that are in this workflow state (see workflow json template) are excluded from the
    # status list and display in the "Published" tab
    self.deposited_workflow_state_name = "deposited"

    def index
      add_breadcrumb t(:"hyrax.controls.home"), root_path
      add_breadcrumb t(:"hyrax.dashboard.breadcrumbs.admin"), hyrax.dashboard_path
      add_breadcrumb t(:"hyrax.admin.sidebar.tasks"), "#"
      add_breadcrumb t(:"hyrax.admin.sidebar.workflow_review"), request.path

      @q = params[:q]
      @batch = params[:batch]
      @status_list = actionable_objects(q: @q, batch_id: @batch).reject(&:published?)
      @published_list = actionable_objects(q: @q, batch_id: @batch).select(&:published?)
      @batches = BatchUpload.order(created_at: :desc)
      @workflow = batch_workflow_presenter @status_list
      @workflow_published = batch_workflow_presenter @published_list
    end

    ##
    # Update workflow actions in batch
    def update
      permitted = params.require(:workflow_action).permit(:name, :comment)

      Hyrax.logger.debug(permitted)

      object_ids = JSON.parse(params[:object_ids])
      object_ids.each do |id|
        work = Hyrax.query_service.find_by(id: id)

        workflow_action = Hyrax::Forms::WorkflowActionForm.new(current_ability: current_ability,
          work: work, attributes: permitted)
        workflow_action.save
      end

      redirect_to(admin_workflows_path,
        notice: "#{t("hyrax.workflows.batch_review.successful")} #{t("hyrax.workflows.batch_review.records_updated")} #{object_ids.length}.")
    end

    private

    ##
    # Ported method from upstream
    def ensure_authorized!
      authorize! :review, :submissions
    end

    ##
    # Extend upstream method actionable_objects to accept query parameter q and batch_id
    # @param q [String] - the keywords for searching
    # batch_id [String] - the batch ID
    def actionable_objects(q:, batch_id:)
      @actionable_objects ||= Hyrax::Workflow::BatchActionableObjects.new(user: current_user, q: q, batch_id: batch_id)
    end

    ##
    # Build WorkflowPresenter when all BatchActionableObjects has the same workflow status
    # @param actionable_objects [BatchActionableObjects]
    # @return [WorkflowPresenter]
    def batch_workflow_presenter(actionable_objects)
      unless @status_list.empty?
        status = actionable_objects.map { |a| a.workflow_state }.uniq
        WorkflowPresenter.new(@status_list.first, current_ability) if status.length == 1
      end
    end
  end
end
