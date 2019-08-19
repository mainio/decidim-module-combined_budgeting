# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class ProjectsController < Decidim::Budgets::ProjectsController
      include CombinedBudgeting::HasCombinedProcess

      helper CombinedBudgeting::BudgetingPathsHelper
      helper CombinedBudgeting::ProjectCellHelper

      layout "layouts/decidim/combined_budgeting/participatory_process"

      def self.controller_path
        "decidim/budgets/projects"
      end
    end
  end
end
