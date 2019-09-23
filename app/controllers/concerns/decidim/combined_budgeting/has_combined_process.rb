# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module CombinedBudgeting
    module HasCombinedProcess
      extend ActiveSupport::Concern

      included do
        helper_method :combined_processes, :current_combined_process
      end

      def current_participatory_space
        current_component.participatory_space
      end

      def current_component
        return unless current_combined_process

        current_combined_process.components.find_by(id: params[:component_id])
      end

      protected

      def organization_combined_processes
        @organization_combined_processes ||= CombinedBudgeting::Process.where(
          organization: current_organization
        )
      end

      def combined_processes
        @combined_processes ||= organization_combined_processes.where.not(published_at: nil)
      end

      def current_combined_process
        return unless params[:process_slug]

        @current_combined_process ||= combined_processes.where(
          slug: params[:process_slug]
        ).first!
      end
    end
  end
end
