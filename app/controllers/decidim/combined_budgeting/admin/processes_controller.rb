# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      class ProcessesController < CombinedBudgeting::Admin::ApplicationController
        include Decidim::Paginable

        helper SelectionHelper
        helper_method :combined_process

        def index
          enforce_permission_to :read, :process_list
          @processes = collection
        end

        def new
          enforce_permission_to :create, :process
          @form = form(Admin::ProcessForm).from_model(
            CombinedBudgeting::Process.new(organization: current_organization)
          )
        end

        def create
          enforce_permission_to :create, :process
          @form = form(Admin::ProcessForm).from_params(params)

          Admin::CreateProcess.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("processes.create.success", scope: "decidim.combined_budgeting.admin")
              redirect_to processes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("processes.create.error", scope: "decidim.combined_budgeting.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :process, process: combined_process
          @form = form(Admin::ProcessForm).from_model(combined_process)
        end

        def update
          enforce_permission_to :update, :process, process: combined_process
          @form = form(Admin::ProcessForm).from_params(
            params,
            process_id: combined_process.id
          )
          Admin::UpdateProcess.call(combined_process, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("processes.update.success", scope: "decidim.combined_budgeting.admin")
              redirect_to processes_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("processes.update.error", scope: "decidim.combined_budgeting.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :process, process: combined_process
          Admin::DestroyProcess.call(combined_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("processes.destroy.success", scope: "decidim.combined_budgeting.admin")
              redirect_to processes_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("processes.destroy.error", scope: "decidim.combined_budgeting.admin")
              redirect_to processes_path
            end
          end
        end

        private

        def processes
          @processes ||= Decidim::CombinedBudgeting::Process.where(
            organization: current_organization
          )
        end

        def query
          @query ||= processes.ransack(params[:q])
        end

        def collection
          @collection ||= paginate(query.result)
        end

        def combined_process
          return unless params["slug"]

          @combined_process ||= processes.where(
            slug: params["slug"]
          ).first!
        end
      end
    end
  end
end
