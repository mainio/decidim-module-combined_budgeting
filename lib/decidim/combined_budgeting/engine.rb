# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CombinedBudgeting

      routes do
        authenticate(:user) do
          resources :processes, path: "budgeting", param: :slug, only: [:index, :show] do
            resources :components, path: "voting", only: [] do
              # resources :projects, only: [:index, :show]
              resources :projects, only: [:show]
              get "/", to: "projects#index", as: :projects

              resource :order, only: [:destroy] do
                member do
                  post :checkout
                end
                resource :line_item, only: [:create, :destroy]
              end
            end
          end
        end

        root to: "processes#index"
      end

      initializer "decidim_combined_budgeting.mount_routes", before: :add_routing_paths do
        Decidim::Core::Engine.routes do
          mount Decidim::CombinedBudgeting::Engine => "/"
        end
      end

      initializer "decidim_combined_budgeting.middleware" do |app|
        app.middleware.insert_after(
          Decidim::CurrentOrganization,
          CombinedBudgeting::Middleware::AuthorizationRedirect
        )
      end

      initializer "decidim_combined_budgeting.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CombinedBudgeting::Engine.root}/app/cells")
      end

      initializer "decidim_combined_budgeting.menu" do
        next unless Decidim::CombinedBudgeting.add_menu_item

        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.combined_budgeting", scope: "decidim"),
                    decidim_combined_budgeting.processes_path,
                    position: 1.1,
                    if: CombinedBudgeting::Process.where(
                      organization: current_organization
                    ).published.any?,
                    active: :inclusive
        end
      end
    end
  end
end
