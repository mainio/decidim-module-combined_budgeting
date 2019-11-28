# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::DestroyProcess do
  let(:form_klass) { Decidim::CombinedBudgeting::Admin::ProcessForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:process) { create :combined_budgeting_process, organization: organization }

  describe "call" do
    let(:subject) { described_class.new(process, user) }

    it "broadcasts ok and destroys the existing process" do
      expect(process).to receive(:destroy!).and_call_original
      expect { subject.call }.to broadcast(:ok)
      expect(Decidim::CombinedBudgeting::Process.count).to eq(0)
    end
  end
end
