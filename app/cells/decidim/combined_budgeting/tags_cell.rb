# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class TagsCell < Decidim::TagsCell
      private

      def category_path
        projects_path(filter: { category_id: model.category.id })
      end

      def scope_path
        projects_path(filter: { scope_id: model.scope.id })
      end

      def projects_path(extra = {})
        decidim_combined_budgeting.process_component_projects_path(
          context[:combined_process],
          model_component,
          extra
        )
      end

      def decidim_budgets
        return super unless model_component

        Decidim::EngineRouter.main_proxy(model_component)
      end

      def model_component
        return nil unless model

        model.component
      end

      def decidim_combined_budgeting
        Decidim::CombinedBudgeting::Engine.routes.url_helpers
      end
    end
  end
end
