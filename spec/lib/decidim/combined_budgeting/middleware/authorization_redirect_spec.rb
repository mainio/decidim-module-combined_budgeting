# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Middleware::AuthorizationRedirect, type: :request do
  include Devise::Test::IntegrationHelpers

  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(id_documents dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:combined_process) do
    create(
      :combined_budgeting_process,
      :published,
      organization: organization
    )
  end

  before do
    # Set the correct host
    host! organization.host

    sign_in user
  end

  describe "GET /authorizations" do
    context "when a process ID exists in the session" do
      before do
        # Generate a dummy session by requesting the home page.
        get "/"
        request.session["active_combined_budgeting_process_id"] = combined_process.id

        get "/authorizations", env: {
          "rack.session" => request.session,
          "rack.session.options" => request.session.options
        }
      end

      it "redirects back to the process" do
        expect(response).to redirect_to("/budgeting/#{combined_process.slug}")
      end

      context "with unpublished process" do
        let(:combined_process) do
          create(
            :combined_budgeting_process,
            organization: organization
          )
        end

        it "renders the authorizations view" do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when a process ID does not exist in the session" do
      it "renders the authorizations view" do
        get "/authorizations"

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /" do
    context "when a process ID exists in the session" do
      it "deletes the process ID from the session" do
        # Generate a dummy session by requesting the home page.
        get "/"
        request.session["active_combined_budgeting_process_id"] = combined_process.id

        # Another request should delete the session variable when the user is
        # not requesting /authorizations
        get "/"
        expect(request.session["active_combined_budgeting_process_id"]).to be(nil)
      end
    end
  end
end
