# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class ComponentMap < ApplicationRecord
      belongs_to :process,
                 foreign_key: "decidim_combined_budgeting_process_id",
                 class_name: "Decidim::CombinedBudgeting::Process"
      belongs_to :component,
                 foreign_key: "decidim_component_id",
                 class_name: "Decidim::Component"
    end
  end
end
