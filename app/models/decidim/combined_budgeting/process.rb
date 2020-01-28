# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class Process < ApplicationRecord
      include Decidim::Publicable
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"
      has_many :component_maps,
               foreign_key: "decidim_combined_budgeting_process_id",
               class_name: "Decidim::CombinedBudgeting::ComponentMap",
               dependent: :destroy
      has_many :components, -> { order(:weight) },
               through: :component_maps,
               foreign_key: "decidim_component_id",
               class_name: "Decidim::Component"

      def to_param
        slug
      end
    end
  end
end
