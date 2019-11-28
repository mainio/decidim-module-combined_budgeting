# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::PublishProcess do
  let(:form_klass) { Decidim::CombinedBudgeting::Admin::ProcessForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:process) { create :combined_budgeting_process, organization: organization }

  describe "call" do
    let(:subject) { described_class.new(process, user) }

    it "broadcasts ok and publishes process" do
      expect(process).to receive(:publish!).and_call_original
      expect { subject.call }.to broadcast(:ok)

      process = Decidim::CombinedBudgeting::Process.last
      expect(process.published?).to be(true)
    end

    context "when the process is nil" do
      let(:process) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is already published" do
      let(:process) { create :combined_budgeting_process, :published, organization: organization }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
