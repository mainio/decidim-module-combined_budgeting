# frozen_string_literal: true

require "spec_helper"

describe "Processes", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  context "when the user is not logged in" do
    let!(:processes) { create_list(:combined_budgeting_process, 2, :published, organization: organization) }

    it "is redirected to the sign in page" do
      page.visit decidim_combined_budgeting.processes_path

      expect(page).to have_current_path(decidim.new_user_session_path)
    end
  end

  describe "index" do
    let(:published_processes) { create_list(:combined_budgeting_process, 2, :published, organization: organization) }
    let(:unpublished_processes) { create_list(:combined_budgeting_process, 5, organization: organization) }
    let!(:processes) { published_processes + unpublished_processes }

    before do
      login_as user, scope: :user
    end

    it "lists all the published processes" do
      page.visit decidim_combined_budgeting.processes_path

      published_processes.each do |pr|
        expect(page).to have_content(translated(pr.title))
      end
    end

    it "does not list any unpublished processes" do
      page.visit decidim_combined_budgeting.processes_path

      unpublished_processes.each do |pr|
        expect(page).not_to have_content(translated(pr.title))
      end
    end
  end

  describe "show" do
    let!(:authorized_components) do
      create_list(
        :budget_component,
        2,
        :with_total_budget_and_vote_threshold_percent,
        manifest: manifest,
        organization: organization
      )
    end
    let!(:unauthorized_component) do
      create(
        :budget_component,
        :with_total_budget_and_vote_threshold_percent,
        manifest: manifest,
        organization: organization
      )
    end
    let!(:combined_process) do
      create(
        :combined_budgeting_process,
        :published,
        organization: organization,
        components: authorized_components + [unauthorized_component],
        authorizations: %w(dummy_authorization_handler)
      )
    end

    before do
      permissions = {
        vote: {
          authorization_handlers: {
            "dummy_authorization_handler" => {}
          }
        }
      }
      unauthorized_component.update!(permissions: permissions)

      login_as user, scope: :user
    end

    it "lists only the spaces of the components the user is authorized to vote in" do
      page.visit decidim_combined_budgeting.process_path(combined_process)

      authorized_components.each do |component|
        expect(page).to have_content(translated(component.participatory_space.title))
      end
      expect(page).not_to have_content(translated(unauthorized_component.participatory_space.title))
    end

    context "when the user has voted in the component" do
      let(:voted_component) { authorized_components.first }
      let!(:projects) { create_list(:project, 3, component: voted_component, budget: 25_000_000) }
      let!(:order) do
        order = create(:order, user: user, component: voted_component)
        order.projects = projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "displays a voted status along with the component" do
        page.visit decidim_combined_budgeting.process_path(combined_process)

        component_content = find(
          ".card__title",
          text: translated(voted_component.participatory_space.title)
        ).find(:xpath, "../..")

        within component_content do
          expect(page).to have_content("Voting completed")
        end
      end
    end
  end
end
