# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class LineItemsController < Decidim::Budgets::LineItemsController
      include CombinedBudgeting::HasCombinedProcess
      include CombinedBudgeting::BudgetingPathsHelper

      helper CombinedBudgeting::BudgetingPathsHelper

      def self.controller_path
        "decidim/budgets/line_items"
      end
    end
  end
end
