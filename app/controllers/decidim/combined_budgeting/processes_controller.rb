# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class ProcessesController < CombinedBudgeting::ApplicationController
      include Decidim::UserProfile
      include CombinedBudgeting::Budgetable

      layout "layouts/decidim/application"

      helper_method :processes, :current_process, :has_voted_on?

      def index
        raise ActionController::RoutingError, "Not Found" if processes.none?

        enforce_permission_to :list, :process

        redirect_to process_path(processes.first) if processes.count == 1
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless current_process.published?

        enforce_permission_to :read, :process, process: current_process

        if confirm_account_step?
          session["active_combined_budgeting_process_id"] = current_process.id
          return render :confirm_account
        end

        if authorize_step?
          session["active_combined_budgeting_process_id"] = current_process.id
          if unauthorized_verifications.count == 1
            verification = unauthorized_verifications.first
            return redirect_to verification.root_path
          end

          return render :authorizations
        end

        @components = authorized_components

        # In case there are no authorized components, a reauthorization may be
        # needed in which case the active combined budgeting process needs to
        # be set.
        session["active_combined_budgeting_process_id"] = current_process.id if @components.count.zero?

        # Render normally in case there is other amount than 1 component
        # available.
        return unless @components.count == 1

        # Redirect the user directly to the voting.
        component = @components.first
        component_path = process_component_projects_path(
          current_process,
          component
        )
        redirect_to component_path
      end

      private

      def confirm_account_step?
        return false if current_user.managed?

        !current_user.confirmed?
      end

      def authorize_step?
        @pending_authorizations = pending_authorizations
        return false if unauthorized_verifications.empty? &&
                        @pending_authorizations.empty?

        true
      end

      def unauthorized_verifications
        @unauthorized_verifications ||= verifications.reject do |handler|
          active_authorization_methods.include?(handler.key)
        end
      end

      def verifications
        @verifications ||= available_verification_workflows.select do |handler|
          current_process.authorizations.include?(handler.key)
        end
      end

      def active_authorization_methods
        Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: current_process.authorizations
        ).reject(&:expired?).pluck(:name)
      end

      def granted_authorizations
        Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          granted: true,
          name: current_process.authorizations
        ).query.reject(&:expired?)
      end

      def pending_authorizations
        Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          name: current_process.authorizations
        ).query.select do |authorization|
          !authorization.granted? || authorization.expired?
        end
      end

      def organization_processes
        @organization_processes ||= CombinedBudgeting::Process.where(
          organization: current_organization
        )
      end

      def processes
        @processes ||= organization_processes.where.not(published_at: nil)
      end

      def current_process
        return unless params[:slug]

        @current_process ||= organization_processes.where(
          slug: params[:slug]
        ).first!
      end
      alias current_combined_process current_process
    end
  end
end
