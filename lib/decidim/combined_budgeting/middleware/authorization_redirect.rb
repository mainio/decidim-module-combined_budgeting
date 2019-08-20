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
          if req.get? && !in_verification?(req)
            if req.path == "/authorizations"
              response = budgeting_redirect_for(req)
              return response if response
            else
              # The user is outside of a verification process and is not in the
              # authorizations root, so we don't need to store this information
              # anymore.
              req.session.delete("active_combined_budgeting_process_id")
            end
          end

          @app.call(env)
        end

        private

        def budgeting_redirect_for(request)
          process_id = request.session.delete(
            "active_combined_budgeting_process_id"
          )
          return unless process_id

          process = CombinedBudgeting::Process.find_by(id: process_id)
          redirect("/budgeting/#{process.slug}") if process
        end

        def in_verification?(request)
          available_verifications_for(request).any? do |verification|
            check_path = verification.root_path.sub(%r{/$}, "")
            # One of the following:
            # /authorization_name
            # /authorization_name/
            # /authorization_name/something
            request.path == check_path || request.path =~ %r{^#{check_path}/.*}
          end
        end

        def available_verifications_for(request)
          organization = request.env["decidim.current_organization"]
          return [] unless organization

          Verifications::Adapter.from_collection(
            organization.available_authorizations &
            Decidim.authorization_workflows.map(&:name)
          )
        end

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
