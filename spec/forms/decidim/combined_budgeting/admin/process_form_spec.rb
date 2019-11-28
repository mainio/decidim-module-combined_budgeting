# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::ProcessForm do
  subject { form }

  let(:organization) { create(:organization) }
  let(:components) do
    [
      create(:component, manifest_name: :budgets, organization: organization),
      create(:component, manifest_name: :budgets, organization: organization)
    ]
  end

  let(:title) { generate_localized_title }
  let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
  let(:authorizations) { %w(id_documents dummy_authorization_handler) }
  let(:slug) { "test-slug" }

  let(:params) do
    {
      title: title,
      description: description,
      slug: slug,
      component_ids: components.map(&:id),
      authorizations: authorizations
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_organization: organization
    )
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when title is empty" do
    let(:title) { Decidim::Faker::Localized.localized { "" } }

    it { is_expected.not_to be_valid }
  end

  context "when slug is empty" do
    let(:slug) { "" }

    it { is_expected.not_to be_valid }
  end

  context "when slug is already in use" do
    before do
      create(
        :combined_budgeting_process,
        :published,
        organization: organization,
        slug: slug
      )
    end

    it { is_expected.not_to be_valid }
  end

  context "when no components are defined" do
    let(:components) { [] }

    it { is_expected.not_to be_valid }
  end
end
