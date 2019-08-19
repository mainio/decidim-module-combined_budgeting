# frozen_string_literal: true

module Decidim
  module CombinedBudgeting
    module Middleware
      class AuthorizationRedirect
        def initialize(app)
          @app = app
        end

        def call(env)
          req = Rack::Request.new(env)
          process_id = req.session["active_combined_budgeting_process_id"]
          if process_id && req.path == "/authorizations" && req.get?
            process = CombinedBudgeting::Process.find_by(id: process_id)
            return redirect("/budgeting/#{process.slug}") if process
          end

          @app.call(env)
        end

        private

        def redirect(location)
          [
            302,
            {
              "Location" => location,
              "Content-Type" => "text/html",
              "Content-Length" => "0"
            },
            []
          ]
        end
      end
    end
  end
end
