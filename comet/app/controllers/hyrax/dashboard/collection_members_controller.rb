# frozen_string_literal: true

module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionMembersController < Hyrax::My::CollectionsController
      before_action :filter_docs_with_read_access!

      ##
      # @!attribute [r] curation_concern
      #   @api private
      #   @return [Hyrax::Resource]
      attr_reader :collection

      load_resource class: Hyrax::PcdmCollection, instance_name: :collection

      include Hyrax::Collections::AcceptsBatches

      def after_update
        respond_to do |format|
          format.html { redirect_to success_return_path, notice: t("hyrax.dashboard.my.action.collection_update_success") }
          format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
        end
      end

      def after_update_error(err_msg)
        respond_to do |format|
          format.html { redirect_to err_return_path, alert: err_msg }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end

      def update_members
        err_msg = validate
        after_update_error(err_msg) if err_msg.present?
        return if err_msg.present?

        begin
          case member_action
          when "add"
            Hyrax::Collections::CollectionMemberService.add_members_by_ids(collection_id: collection.id,
              new_member_ids: batch_ids,
              user: current_user)
          when "remove"
            Hyrax::Collections::CollectionMemberService.remove_members_by_ids(collection_id: collection.id,
              member_ids: batch_ids,
              user: current_user)
          else
            after_update_error("#{t("hyrax.dashboard.my.action.not_implemeted")}: #{member_action}")
            return
          end

          after_update
        rescue Hyrax::SingleMembershipError => err
          messages = JSON.parse(err.message)
          if messages.size == batch_ids.size
            after_update_error(messages.uniq.join(", "))
          elsif messages.present?
            flash[:error] = messages.uniq.join(", ")
            after_update
          end
        end
      end

      private

      def validate
        return t("hyrax.dashboard.my.action.members_no_access") if batch_ids.blank?
        t("hyrax.dashboard.my.action.collection_deny_add_members") unless current_ability.can?(:deposit, collection)
      end

      def success_return_path
        dashboard_collection_path(collection.id)
      end

      def err_return_path
        dashboard_collections_path
      end

      def batch_ids
        params[:batch_document_ids]
      end

      def member_action
        params[:collection][:members]
      end
    end
  end
end
