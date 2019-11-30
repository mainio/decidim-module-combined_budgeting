# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::ProcessPublicationsController, type: :controller do
  routes { Decidim::CombinedBudgeting::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  describe "POST create" do
    let(:combined_process) { create(:combined_budgeting_process, organization: organization) }

    it "publishes an unpublised process" do
      post :create, params: { process_slug: combined_process.slug }

      expect(flash[:notice]).not_to be_empty
      expect(response).to redirect_to(processes_path)

      process = Decidim::CombinedBudgeting::Process.last
      expect(process.published?).to be(true)
    end

    context "when trying to publish a published process" do
      let(:combined_process) { create(:combined_budgeting_process, :published, organization: organization) }

      it "publishes an unpublised process" do
        post :create, params: { process_slug: combined_process.slug }

        expect(flash[:alert]).not_to be_empty
        expect(response).to redirect_to(processes_path)
      end
    end
  end

  describe "DELETE destroy" do
    let(:combined_process) { create(:combined_budgeting_process, :published, organization: organization) }

    it "publishes an unpublised process" do
      delete :destroy, params: { process_slug: combined_process.slug }

      expect(flash[:notice]).not_to be_empty
      expect(response).to redirect_to(processes_path)

      process = Decidim::CombinedBudgeting::Process.last
      expect(process.published?).to be(false)
    end

    context "when trying to unpublish an unpublished process" do
      let(:combined_process) { create(:combined_budgeting_process, organization: organization) }

      it "publishes an unpublised process" do
        delete :destroy, params: { process_slug: combined_process.slug }

        expect(flash[:alert]).not_to be_empty
        expect(response).to redirect_to(processes_path)
      end
    end
  end
end
