# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # A form object to be used when admin users want to create a process.
      class ProcessForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :slug, String

        attribute :authorizations, Array[String]
        attribute :component_ids, Array[Integer]

        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }
        validates :title, translatable_presence: true
        validates :component_ids, presence: true
        validate :slug_uniqueness

        # Needs an override to map the i18n keys to the correct namespace
        def self.model_name
          ActiveModel::Name.new(self, nil, "Decidim::CombinedBudgeting::Process")
        end

        # Needs an override to map the request params to the correct namespace
        def self.mimicked_model_name
          model_name.param_key
        end

        private

        def organization_processes
          CombinedBudgeting::Process.where(organization: current_organization)
        end

        def slug_uniqueness
          return unless organization_processes
                        .where(slug: slug)
                        .where.not(id: context[:process_id])
                        .any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
