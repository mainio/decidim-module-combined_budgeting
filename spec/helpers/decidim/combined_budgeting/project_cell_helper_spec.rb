# frozen_string_literal: true

require "spec_helper"

describe Decidim::CombinedBudgeting::ProjectCellHelper do
  # Hack a custom class to test that the super method is called with the correct
  # arguments.
  let(:klass) do
    Class.new do
      prepend Decidim::CombinedBudgeting::ProjectCellHelper

      def cell(name, model, options = {}, &block)
        cell_super(name, model, options, &block)
      end

      def cell_super(name, model, options = {}, &block); end
    end
  end

  let(:helper) { klass.new }

  let(:organization) { current_combined_process.organization }
  let(:current_combined_process) { create(:combined_budgeting_process, :published) }

  before do
    allow(helper).to receive(:current_combined_process).and_return(current_combined_process)
  end

  describe "#cell" do
    let(:model) { double }

    it "modifies the arguments passed to the super class" do
      expect(helper).to receive(:cell_super).with(
        "decidim/combined_budgeting/tags",
        model,
        context: { combined_process: current_combined_process }
      )

      helper.cell("decidim/tags", model)
    end
  end
end
