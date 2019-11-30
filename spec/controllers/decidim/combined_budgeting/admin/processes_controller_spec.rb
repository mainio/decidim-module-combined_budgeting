# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::Admin::ProcessesController, type: :controller do
  routes { Decidim::CombinedBudgeting::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  describe "GET index" do
    render_views

    before do
      create_list(:combined_budgeting_process, 21, :published, organization: organization)
      create_list(:combined_budgeting_process, 5, organization: organization)
    end

    it "renders the index listing" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:index)
      expect(assigns(:processes).length).to eq(20)
    end
  end

  describe "GET new" do
    it "renders the empty form" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:new)
    end
  end

  describe "POST create" do
    let(:components) do
      [
        create(:component, manifest_name: :budgets, organization: organization),
        create(:component, manifest_name: :budgets, organization: organization)
      ]
    end

    it "creates a combined budgeting process" do
      post :create, params: {
        title: generate_localized_title,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
        slug: generate(:slug),
        component_ids: components.map(&:id)
      }

      expect(flash[:notice]).not_to be_empty
      expect(response).to redirect_to(processes_path)
      expect(Decidim::CombinedBudgeting::Process.count).to eq(1)
    end

    context "when the form is not valid" do
      it "does not create a combined budgeting process" do
        post :create, params: {
          title: Decidim::Faker::Localized.localized { "" },
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          slug: generate(:slug),
          component_ids: components.map(&:id)
        }

        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:new)
        expect(Decidim::CombinedBudgeting::Process.count).to eq(0)
      end
    end
  end

  describe "GET edit" do
    let(:combined_process) { create(:combined_budgeting_process, :published, organization: organization) }

    it "renders the edit view" do
      get :edit, params: { slug: combined_process.slug }
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:edit)
    end
  end

  describe "PATCH update" do
    let(:combined_process) { create(:combined_budgeting_process, :published, organization: organization) }

    let(:components) do
      [
        create(:component, manifest_name: :budgets, organization: organization),
        create(:component, manifest_name: :budgets, organization: organization)
      ]
    end

    it "updates the combined budgeting process" do
      title = generate_localized_title
      description = Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title }
      slug = generate(:slug)

      patch :update, params: {
        slug: combined_process.slug,
        decidim_combined_budgeting_process: {
          title: title,
          slug: slug,
          description: description,
          component_ids: components.map(&:id)
        }
      }

      expect(flash[:notice]).not_to be_empty
      expect(response).to redirect_to(processes_path)

      process = Decidim::CombinedBudgeting::Process.last
      expect(process.title).to eq(title)
      expect(process.description).to eq(description)
      expect(process.slug).to eq(slug)
      expect(process.components.pluck(:id)).to match_array(components.map(&:id))
    end

    context "when the form is not valid" do
      it "does not update the combined budgeting process" do
        patch :update, params: {
          slug: combined_process.slug,
          decidim_combined_budgeting_process: {
            title: Decidim::Faker::Localized.localized { "" },
            slug: generate(:slug),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
            component_ids: components.map(&:id)
          }
        }

        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:edit)
      end
    end
  end

  describe "DELETE destroy" do
    let(:combined_process) { create(:combined_budgeting_process, :published, organization: organization) }

    it "updates the combined budgeting process" do
      delete :destroy, params: { slug: combined_process.slug }

      expect(Decidim::CombinedBudgeting::Process.count).to eq(0)
    end
  end
end
