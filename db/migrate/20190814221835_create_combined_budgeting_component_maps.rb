# frozen_string_literal: true

class CreateCombinedBudgetingComponentMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_combined_budgeting_component_maps do |t|
      t.references :decidim_combined_budgeting_process, null: false, foreign_key: true, index: { name: "index_combined_budgeting_process_compmaps_on_process" }
      t.references(
        :decidim_component,
        null: false,
        foreign_key: { on_delete: :cascade },
        index: { name: "index_combined_budgeting_process_compmaps_on_component" }
      )
    end
  end
end
