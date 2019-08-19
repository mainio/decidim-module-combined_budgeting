# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app" do
  # Copy the initializer and translation file to the development app folder
  # base_path = __dir__
  # source_path = "#{base_path}/lib/decidim/combined_budgeting/generators/app_templates"
  # target_path = "#{base_path}/development_app/config"
  # FileUtils.cp(
  #   "#{source_path}/initializer.rb",
  #   "#{target_path}/initializers/decidim_verifications_combined_budgeting.rb"
  # )
  # FileUtils.cp(
  #   "#{source_path}/en.yml",
  #   "#{target_path}/locales/decidim-combined_budgeting.en.yml"
  # )
  #
  # # Seed the DB after the initializer has been installed
  # Dir.chdir("development_app") do
  #   system("bundle exec rake db:seed")
  # end
end
