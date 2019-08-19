# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # A command with all the business logic when updating a combined budgeting
      # process in the system.
      class UpdateProcess < Rectify::Command
        attr_reader :process
        # Public: Initializes the command.
        #
        # process - the CombinedBudgeting::Process to update
        # form - A form object with the params.
        def initialize(process, form)
          @process = process
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

          update_process
          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_process
          Decidim.traceability.update!(
            process,
            form.current_user,
            attributes
          )
        end

        def attributes
          {
            slug: form.slug,
            title: form.title,
            description: form.description,
            authorizations: form.authorizations.reject(&:empty?),
            component_ids: form.component_ids
          }
        end
      end
    end
  end
end
