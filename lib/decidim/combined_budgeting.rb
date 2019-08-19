# frozen_string_literal: true

require_relative "combined_budgeting/version"
require_relative "combined_budgeting/middleware"
require_relative "combined_budgeting/engine"
require_relative "combined_budgeting/admin"
require_relative "combined_budgeting/admin_engine"

module Decidim
  module CombinedBudgeting
    include ActiveSupport::Configurable

    config_accessor :add_menu_item do
      true
    end
  end
end
