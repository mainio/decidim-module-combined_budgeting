# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module ProjectCellHelper
      def cell(name, model, options = {}, &block)
        # Override the tags cells for proper linking to the projects path
        if name == "decidim/tags"
          name = "decidim/combined_budgeting/tags"
          options[:context] ||= {}
          options[:context][:combined_process] = current_combined_process
        end

        super(name, model, options, &block)
      end
    end
  end
end
