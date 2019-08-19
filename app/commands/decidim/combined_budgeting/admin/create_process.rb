# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # A command with all the business logic when creating a new combined
      # budgeting process in the system.
      class CreateProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_process
          broadcast(:ok)
        end

        private

        attr_reader :form, :process

        def create_process
          Decidim.traceability.perform_action!(
            :create,
            CombinedBudgeting::Process,
            form.current_user
          ) do
            process = CombinedBudgeting::Process.create!(attributes)
            map_components(process)
            process
          end
        end

        def map_components(process)
          process.update!(component_ids: form.component_ids)
        end

        def attributes
          {
            organization: form.current_organization,
            slug: form.slug,
            title: form.title,
            description: form.description,
            authorizations: form.authorizations.reject(&:empty?)
          }
        end
      end
    end
  end
end
