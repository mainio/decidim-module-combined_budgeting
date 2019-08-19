# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # Controller that allows managing participatory process publications.
      #
      class ProcessPublicationsController < CombinedBudgeting::Admin::ApplicationController
        def create
          enforce_permission_to :publish, :process, process: combined_process

          Admin::PublishProcess.call(combined_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("process_publications.create.success", scope: "decidim.combined_budgeting.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("process_publications.create.error", scope: "decidim.combined_budgeting.admin")
            end

            redirect_back(fallback_location: processes_path)
          end
        end

        def destroy
          enforce_permission_to :publish, :process, process: combined_process

          Admin::UnpublishProcess.call(combined_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("process_publications.destroy.success", scope: "decidim.combined_budgeting.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("process_publications.destroy.error", scope: "decidim.combined_budgeting.admin")
            end

            redirect_back(fallback_location: processes_path)
          end
        end

        private

        def combined_process
          @combined_process ||= Decidim::CombinedBudgeting::Process.find(params[:process_id])
        end
      end
    end
  end
end
