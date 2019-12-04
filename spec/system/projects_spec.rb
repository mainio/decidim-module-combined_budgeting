# frozen_string_literal: true

require "spec_helper"

describe "Projects", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:project) { projects.first }

  let!(:component) do
    create(:budget_component,
           :with_total_budget_and_vote_threshold_percent,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:combined_process) do
    create(
      :combined_budgeting_process,
      :published,
      organization: organization,
      components: [component]
    )
  end

  context "when the user is not logged in" do
    let!(:projects) { create_list(:project, 1, component: component, budget: 25_000_000) }

    it "is redirected to the sign in page" do
      visit_component

      expect(page).to have_current_path(decidim.new_user_session_path)
    end
  end

  describe "index" do
    before do
      login_as user, scope: :user
    end

    it "respects the projects_per_page setting when under total projects" do
      component.update!(settings: { projects_per_page: 1 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 1)
    end

    it "respects the projects_per_page setting when it matches total projects" do
      component.update!(settings: { projects_per_page: 2 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end

    it "respects the projects_per_page setting when over total projects" do
      component.update!(settings: { projects_per_page: 3 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end
  end

  describe "show" do
    let!(:project) { create(:project, component: component, budget: 25_000_000) }

    before do
      login_as user, scope: :user

      page.visit decidim_combined_budgeting.process_component_project_path(combined_process, component, project)
    end

    it_behaves_like "has attachments" do
      let(:attached_to) { project }
    end

    it "shows the component" do
      expect(page).to have_i18n_content(project.title)
      expect(page).to have_i18n_content(project.description)
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: project.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

      before do
        project.link_resources(proposals, "included_proposals")
      end

      it "shows related proposals" do
        visit_component
        click_link translated(project.title)

        proposals.each do |proposal|
          expect(page).to have_content(proposal.title)
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end
  end

  def visit_component
    page.visit decidim_combined_budgeting.process_component_projects_path(combined_process, component)
  end
end
