# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::BudgetingPathsHelper do
  let(:organization) { current_component.organization }
  let(:current_component) { create(:budget_component, :published) }
  let(:current_combined_process) do
    create(
      :combined_budgeting_process,
      :published,
      organization: current_component.organization
    )
  end
  let(:decidim_combined_budgeting) do
    Decidim::CombinedBudgeting::Engine.routes.url_helpers
  end

  before do
    allow(helper).to receive(:decidim_combined_budgeting).and_return(decidim_combined_budgeting)
    allow(helper).to receive(:current_combined_process).and_return(current_combined_process)
    allow(helper).to receive(:current_component).and_return(current_component)
  end

  describe "#projects_path" do
    it "returns the correct path" do
      path = format(
        "/budgeting/%{slug}/voting/%{component_id}",
        slug: current_combined_process.slug,
        component_id: current_component.id
      )
      expect(helper.projects_path).to eq(path)
    end
  end

  describe "#project_path" do
    let(:project) { create(:project, component: current_component) }

    it "returns the correct path" do
      path = format(
        "/budgeting/%{slug}/voting/%{component_id}/projects/%{project_id}",
        slug: current_combined_process.slug,
        component_id: current_component.id,
        project_id: project.id
      )
      expect(helper.project_path(project)).to eq(path)
    end
  end

  describe "#order_path" do
    it "returns the correct path" do
      path = format(
        "/budgeting/%{slug}/voting/%{component_id}/order",
        slug: current_combined_process.slug,
        component_id: current_component.id
      )
      expect(helper.order_path).to eq(path)
    end
  end

  describe "#order_line_item_path" do
    let(:project) { create(:project, component: current_component) }

    it "returns the correct path" do
      path = format(
        "/budgeting/%{slug}/voting/%{component_id}/order/line_item?project_id=%{project_id}",
        slug: current_combined_process.slug,
        component_id: current_component.id,
        project_id: project.id
      )
      expect(helper.order_line_item_path(project_id: project.id)).to eq(path)
    end
  end

  # Call to a path that is not defined within the helper itself
  describe "#checkout_order_path" do
    it "returns the correct path" do
      path = format(
        "/budgeting/%{slug}/voting/%{component_id}/order/checkout",
        slug: current_combined_process.slug,
        component_id: current_component.id
      )
      expect(helper.checkout_order_path).to eq(path)
    end
  end
end
