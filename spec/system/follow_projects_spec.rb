# frozen_string_literal: true

require "spec_helper"

describe "Follow projects", type: :system do
  let(:manifest_name) { "budgets" }

  let!(:combined_process) do
    create(
      :combined_budgeting_process,
      :published,
      organization: organization,
      components: [component]
    )
  end

  let!(:followable) do
    create(:project, component: component)
  end

  let(:followable_path) do
    decidim_combined_budgeting.process_component_project_path(combined_process, component, followable)
  end

  include_context "with a component"

  before do
    login_as user, scope: :user
  end

  context "when not following the followable" do
    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        expect do
          click_button "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end

  context "when the user is following the followable" do
    before do
      create(:follow, followable: followable, user: user)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        expect do
          click_button "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end
