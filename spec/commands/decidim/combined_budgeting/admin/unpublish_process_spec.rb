# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::UnpublishProcess do
  let(:form_klass) { Decidim::CombinedBudgeting::Admin::ProcessForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:process) { create :combined_budgeting_process, :published, organization: organization }

  describe "call" do
    let(:subject) { described_class.new(process, user) }

    it "broadcasts ok and unpublishes process" do
      expect(process).to receive(:unpublish!).and_call_original
      expect { subject.call }.to broadcast(:ok)

      process = Decidim::CombinedBudgeting::Process.last
      expect(process.published?).to be(false)
    end

    context "when the process is nil" do
      let(:process) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is not published" do
      let(:process) { create :combined_budgeting_process, organization: organization }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
