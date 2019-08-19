# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module CombinedBudgeting
    module Budgetable
      extend ActiveSupport::Concern

      protected

      def has_voted_on?(component)
        order = Decidim::Budgets::Order.find_by(
          component: component,
          user: current_user
        )
        return false unless order

        order.checked_out?
      end
    end
  end
end
