# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::UpdateProcess do
  let(:form_klass) { Decidim::CombinedBudgeting::Admin::ProcessForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:process) { create :combined_budgeting_process, :published, organization: organization }
  let(:components) do
    [
      create(:component, manifest_name: :budgets, organization: organization),
      create(:component, manifest_name: :budgets, organization: organization)
    ]
  end
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  describe "call" do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.localized { "Updated title" },
        description: Decidim::Faker::Localized.localized { "Updated description" },
        slug: "updated-slug",
        component_ids: components.map(&:id)
      }
    end

    let(:command) do
      described_class.new(process, form)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the title" do
        original_process = process

        command.call

        process = Decidim::CombinedBudgeting::Process.last
        expect(process.title).to eq(original_process.title)
        expect(process.description).to eq(original_process.description)
        expect(process.components.pluck(:id)).to match_array(original_process.components.pluck(:id))
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the process" do
        command.call

        process = Decidim::CombinedBudgeting::Process.last

        expect(process.title).to include(
          Decidim::Faker::Localized.localized { "Updated title" }
        )
        expect(process.description).to include(
          Decidim::Faker::Localized.localized { "Updated description" }
        )
        expect(process.slug).to eq("updated-slug")
        expect(process.components.pluck(:id)).to match_array(components.map(&:id))
      end
    end
  end
end
