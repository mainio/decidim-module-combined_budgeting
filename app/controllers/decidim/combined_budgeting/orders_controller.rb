# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class OrdersController < Decidim::Budgets::OrdersController
      include CombinedBudgeting::HasCombinedProcess
      include CombinedBudgeting::BudgetingPathsHelper
    end
  end
end
