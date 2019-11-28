# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::SelectionHelper do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(id_documents dummy_authorization_handler)
    )
  end
  let!(:components) do
    Array.new(10).map do
      create(:budget_component, :published, organization: organization)
    end
  end

  before do
    helper.class.send(:include, Decidim::TranslatableAttributes)
    allow(helper).to receive(:current_organization).and_return(organization)
  end

  describe "#components_for_select" do
    it "returns the correct components for selection" do
      expected = components.map do |component|
        name = component.participatory_space.title[I18n.locale.to_s]
        name += " (##{component.participatory_space.id})"
        name += " - #{component.name[I18n.locale.to_s]} (##{component.id})"
        [name, component.id]
      end

      selection = helper.components_for_select
      cmps = selection[0][1]
      expect(cmps).to match_array(expected)
    end
  end

  describe "#authorizations_for_select" do
    it "returns the correct authorizations for selection" do
      expected = organization.available_authorizations.map do |name|
        workflow = Decidim::Verifications.find_workflow_manifest(name)
        next unless workflow

        [workflow.description, workflow.name]
      end.compact

      expect(helper.authorizations_for_select).to match_array(expected)
    end
  end
end
