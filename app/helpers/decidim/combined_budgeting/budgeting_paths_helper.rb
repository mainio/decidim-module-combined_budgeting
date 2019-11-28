# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module BudgetingPathsHelper
      def projects_path
        decidim_combined_budgeting.process_component_projects_path(
          current_combined_process,
          current_component
        )
      end

      def project_path(project)
        decidim_combined_budgeting.process_component_project_path(
          current_combined_process,
          current_component,
          project
        )
      end

      def order_path
        decidim_combined_budgeting.process_component_order_path(
          current_combined_process,
          current_component
        )
      end

      def checkout_order_path
        decidim_combined_budgeting.checkout_process_component_order_path(
          current_combined_process,
          current_component
        )
      end

      def order_line_item_path(*args)
        decidim_combined_budgeting.process_component_order_line_item_path(
          current_combined_process,
          current_component,
          *args
        )
      end

      def method_missing(method, *args)
        return decidim_budgets.send(method, *args) if method.to_s =~ /_(path|url)$/

        super
      end

      def respond_to_missing?(method, include_private = false)
        return true if method.to_s =~ /_(path|url)$/

        super
      end

      private

      def decidim_budgets
        return nil unless current_component

        Decidim::EngineRouter.main_proxy(current_component)
      end
    end
  end
end
