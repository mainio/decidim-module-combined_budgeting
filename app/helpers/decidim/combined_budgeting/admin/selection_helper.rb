# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Admin
      # This class contains helpers needed to format components and
      # authorizations in order to use them in select forms.
      #
      module SelectionHelper
        # Public: A formatted collection of Decidim::Components to be used
        # in forms.
        #
        # Returns an Array.
        def components_for_select
          @components_for_select ||= begin
            query = Decidim::Component.where(manifest_name: "budgets")
            where = []
            bindvars = []
            Decidim.participatory_space_manifests.map do |m|
              tbl = m.model_class_name.constantize.table_name
              join = "LEFT OUTER JOIN #{tbl} ON #{tbl}.id = decidim_components.participatory_space_id"
              join += " AND decidim_components.participatory_space_type = "
              join += ActiveRecord::Base.connection.quote(m.model_class_name)
              query = query.joins(join)
              where << "#{tbl}.decidim_organization_id =?"
              bindvars << current_organization.id
            end
            query = query.where(where.join(" OR "), *bindvars)

            # First create the groups
            space_components = {}
            query.each do |component|
              group = component.participatory_space.model_name.human
              space_components[group] ||= []

              name = translated_attribute(component.participatory_space.title)
              name += " (##{component.participatory_space.id})"
              name += " - #{translated_attribute(component.name)} (##{component.id})"
              space_components[group] << [name, component.id]
            end

            # Then map the groups for the view
            space_components.map do |group_name, items|
              [group_name, items]
            end
          end
        end

        # Public: A formatted collection of workflow manifests to be used
        # in forms.
        #
        # Returns an Array.
        def authorizations_for_select
          @authorizations_for_select ||=
            current_organization.available_authorizations.map do |name|
              workflow = Decidim::Verifications.find_workflow_manifest(name)
              next unless workflow

              [workflow.description, workflow.name]
            end.compact
        end
      end
    end
  end
end
