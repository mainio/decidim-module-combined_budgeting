# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::ProcessesController, type: :controller do
  routes { Decidim::CombinedBudgeting::Engine.routes }

  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(id_documents dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  describe "GET index" do
    render_views

    context "when there is only one process" do
      let!(:processes) { create_list(:combined_budgeting_process, 1, :published, organization: organization) }

      it "redirects to the first process" do
        get :index
        expect(subject).to redirect_to(process_path(processes.first))
      end
    end

    context "when there are multiple processes but only one published" do
      let!(:published_process) do
        create(:combined_budgeting_process, :published, organization: organization)
      end
      let!(:processes) do
        list = create_list(:combined_budgeting_process, 3, organization: organization)
        list << published_process
        list
      end

      it "redirects to the first process" do
        get :index
        expect(subject).to redirect_to(process_path(published_process))
      end
    end

    context "when there are multiple processes" do
      let!(:processes) { create_list(:combined_budgeting_process, 3, :published, organization: organization) }

      it "renders the list of processes" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:index)
        expect(assigns(:processes).count).to eq(processes.count)
      end
    end

    context "when there are multiple processes some of which are unpublished" do
      let(:published_processes) { create_list(:combined_budgeting_process, 2, :published, organization: organization) }
      let(:unpublished_processes) { create_list(:combined_budgeting_process, 5, organization: organization) }
      let!(:processes) { published_processes + unpublished_processes }

      it "renders the list of published processes" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:index)
        expect(assigns(:processes).count).to eq(published_processes.count)
      end
    end
  end

  describe "GET show" do
    render_views

    context "with one unauthorized required authorization" do
      let(:combined_process) do
        create(
          :combined_budgeting_process,
          :published,
          organization: organization,
          authorizations: ["id_documents"]
        )
      end

      it "redirects to the authorization" do
        get :show, params: { slug: combined_process.slug }

        expect(subject).to redirect_to("/id_documents/")
      end
    end

    context "with two unauthorized required authorization" do
      let(:components) do
        [
          create(:component, manifest_name: :budgets, organization: organization),
          create(:component, manifest_name: :budgets, organization: organization)
        ]
      end

      let(:combined_process) do
        create(
          :combined_budgeting_process,
          :published,
          organization: organization,
          authorizations: %w(id_documents dummy_authorization_handler)
        )
      end

      it "renders the authorization selection view" do
        get :show, params: { slug: combined_process.slug }

        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:authorizations)
      end
    end

    context "with one authorized and one unauthorized of two required authorizations" do
      let(:combined_process) do
        create(
          :combined_budgeting_process,
          :published,
          organization: organization,
          authorizations: %w(id_documents dummy_authorization_handler)
        )
      end

      before do
        authorization = Decidim::Authorization.create!(
          unique_id: "test",
          name: "id_documents",
          user: user
        )

        # This will update the "granted_at" timestamp of the authorization
        # which will postpone expiration on re-authorizations in case the
        # authorization is set to expire (by default it will not expire).
        authorization.grant!
      end

      it "redirects to the unauthorized authorization" do
        get :show, params: { slug: combined_process.slug }

        expect(subject).to redirect_to("/authorizations/new?handler=dummy_authorization_handler")
      end
    end

    context "with the user authorized with all of the required authorizations" do
      let(:combined_process) do
        create(
          :combined_budgeting_process,
          :published,
          organization: organization,
          components: components,
          authorizations: %w(id_documents)
        )
      end

      before do
        authorization = Decidim::Authorization.create!(
          unique_id: "test",
          name: "id_documents",
          user: user
        )

        # This will update the "granted_at" timestamp of the authorization
        # which will postpone expiration on re-authorizations in case the
        # authorization is set to expire (by default it will not expire).
        authorization.grant!
      end

      context "and one component attached" do
        let(:components) do
          [
            create(:component, manifest_name: :budgets, organization: organization)
          ]
        end

        it "redirects to the correct component" do
          get :show, params: { slug: combined_process.slug }

          expect(subject).to redirect_to(
            process_component_projects_path(combined_process, components.first)
          )
        end
      end

      context "and two components attached" do
        let(:components) do
          [
            create(:component, manifest_name: :budgets, organization: organization),
            create(:component, manifest_name: :budgets, organization: organization)
          ]
        end

        it "redirects to the correct component" do
          get :show, params: { slug: combined_process.slug }

          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:show)
        end
      end
    end
  end
end
