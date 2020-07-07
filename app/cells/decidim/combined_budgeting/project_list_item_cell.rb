# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    # This cell renders a horizontal project card
    # for an given instance of a Project in a budget list
    class ProjectListItemCell < ::Decidim::Budgets::ProjectListItemCell
      include Decidim::CombinedBudgeting::Engine.routes.url_helpers

      delegate :current_combined_process, to: :parent_controller

      private

      def resource_path
        process_component_project_path(
          current_combined_process,
          current_component,
          model
        )
      end

      def order_line_item_path(defs)
        defs[:process_slug] ||= current_combined_process.slug
        defs[:component_id] ||= current_component.id

        process_component_order_line_item_path(defs)
      end
    end
  end
end
