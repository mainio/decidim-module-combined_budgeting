# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless permission_action.scope == :public

        return permission_action if process && !process.is_a?(
          Decidim::CombinedBudgeting::Process
        )

        return permission_action unless user

        public_list_processes_action?
        public_read_process_action?

        permission_action
      end

      private

      def public_list_processes_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :process

        allow!
      end

      def public_read_process_action?
        return unless permission_action.action == :read &&
                      permission_action.subject == :process &&
                      process

        return allow! if user&.admin?
        return allow! if process.published?

        toggle_allow(can_manage_process?)
      end

      def process
        @process ||= context.fetch(:process, nil)
      end
    end
  end
end
