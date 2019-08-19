# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CombinedBudgeting::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :processes, param: :slug, except: [:show] do
          resource :publish, controller: "process_publications", only: [:create, :destroy]
        end

        root to: "processes#index"
      end

      initializer "decidim_combined_budgeting.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::CombinedBudgeting::AdminEngine, at: "/admin/combined_budgeting", as: "decidim_admin_combined_budgeting"
        end
      end

      initializer "decidim_combined_budgeting.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.combined_budgeting", scope: "decidim.admin"),
                    decidim_admin_combined_budgeting.processes_path,
                    icon_name: "euro",
                    position: 3.1,
                    active: :inclusive,
                    if: allowed_to?(:enter, :space_area, space_name: :processes, organization: current_organization)
        end
      end
    end
  end
end
