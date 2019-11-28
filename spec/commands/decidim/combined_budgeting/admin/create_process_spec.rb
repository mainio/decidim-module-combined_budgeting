# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::CreateProcess do
  let(:form_klass) { Decidim::CombinedBudgeting::Admin::ProcessForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
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
        title: generate_localized_title,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
        slug: generate(:slug),
        component_ids: components.map(&:id)
      }
    end

    let(:command) do
      described_class.new(form)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create a process" do
        expect do
          command.call
        end.not_to change(Decidim::CombinedBudgeting::Process, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new process" do
        expect do
          command.call
        end.to change(Decidim::CombinedBudgeting::Process, :count).by(1)
      end

      it "links the components" do
        command.call
        process = Decidim::CombinedBudgeting::Process.last

        component_ids = components.map(&:id)
        expect(process.components.pluck(:id)).to match_array(component_ids)
      end
    end
  end
end
