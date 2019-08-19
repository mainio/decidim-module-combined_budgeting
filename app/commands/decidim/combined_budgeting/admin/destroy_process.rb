# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # A command that destroys a combined budgeting process in the system.
      class DestroyProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # process - A CombinedBudgeting::Process that will be destroyed
        # current_user - the user performing the action
        def initialize(process, current_user)
          @process = process
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          transaction do
            Decidim.traceability.perform_action!(:delete, process, current_user) do
              process.destroy!
              process
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :process
      end
    end
  end
end
