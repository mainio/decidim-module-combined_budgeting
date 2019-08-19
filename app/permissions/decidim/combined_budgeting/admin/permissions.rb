# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          if read_admin_dashboard_action?
            allow!
            return permission_action
          end

          user_can_read_process_list?
          user_can_read_current_process?
          user_can_create_process?
          user_can_update_process?

          # org admins can do everything in the admin section
          org_admin_action?

          permission_action
        end

        private

        # It's an admin user if it's an organization admin or is a space admin
        # for the current `process`.
        def admin_user?
          user.admin? || has_manageable_processes?
        end

        # Checks if it has any manageable process, with any possible role.
        def has_manageable_processes?
          return unless user

          CombinedBudgeting::Process.any?
        end

        # Everyone can read the process list
        def user_can_read_process_list?
          return unless read_process_list_permission_action?

          toggle_allow(user.admin? || has_manageable_processes?)
        end

        def user_can_read_current_process?
          return unless read_process_list_permission_action?
          return if permission_action.subject == :process_list

          toggle_allow(user.admin? || can_manage_process?)
        end

        # Only organization admins can create a process
        def user_can_create_process?
          return unless permission_action.action == :create &&
                        permission_action.subject == :process

          toggle_allow(user.admin?)
        end

        # Only organization admins can create a process
        def user_can_update_process?
          process = context.fetch(:process, nil)
          return unless process
          return unless permission_action.action == :update &&
                        permission_action.subject == :process

          toggle_allow(user.admin?)
        end

        def org_admin_action?
          return unless user.admin?

          allow! if permission_action.subject == :process
        end

        # Checks if the permission_action is to read the admin processes list or
        # not.
        def read_process_list_permission_action?
          permission_action.action == :read &&
            [:process, :process_list].include?(permission_action.subject)
        end

        def read_admin_dashboard_action?
          permission_action.action == :read &&
            permission_action.subject == :admin_dashboard
        end
      end
    end
  end
end
