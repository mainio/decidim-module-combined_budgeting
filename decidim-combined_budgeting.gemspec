# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/combined_budgeting/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-combined_budgeting"
  spec.version = Decidim::CombinedBudgeting::VERSION
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Combine budgeting process from multiple spaces to one."
  spec.description = "Allows combining the budgeting process from multiple participatory spaces to a single process."
  spec.homepage = "https://github.com/mainio/decidim-module-combined_budgeting"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::CombinedBudgeting::DECIDIM_VERSION
  spec.add_dependency "decidim-budgets", Decidim::CombinedBudgeting::DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::CombinedBudgeting::DECIDIM_VERSION
  spec.add_dependency "decidim-verifications", Decidim::CombinedBudgeting::DECIDIM_VERSION

  spec.add_development_dependency "decidim-dev", Decidim::CombinedBudgeting::DECIDIM_VERSION
end
