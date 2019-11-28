# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :combined_budgeting_process, class: "Decidim::CombinedBudgeting::Process" do
    transient do
      components { [] }
      components_amount { 1 }
    end

    organization { create(:organization) }
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    slug { generate(:slug) }
    authorizations { %w(id_documents dummy_authorization_handler) }

    after(:create) do |process, evaluator|
      components = evaluator.components
      if components.empty?
        components = Array.new(evaluator.components_amount).map do
          create(:component, manifest_name: :budgets, organization: process.organization)
        end
      end

      components.each do |component|
        process.component_maps.create!(component: component)
      end
    end

    trait :published do
      published_at { Time.current }
    end
  end
end
