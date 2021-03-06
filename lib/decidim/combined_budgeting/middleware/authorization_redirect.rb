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

          return @app.call(env) if req.get? && direct_request?(req)

          if req.get? && !in_verification?(req)
            if budget_redirect_request?(req)
              response = budgeting_redirect_for(req)
              return response if response
            elsif req.path !~ %r{^/users/.*$}
              # The user is outside of a verification process and is not in the
              # authorizations root, so we don't need to store this information
              # anymore.
              req.session.delete("active_combined_budgeting_process_id")
            end
          end

          response = @app.call(env)

          # Set the newly confirmed session variable after processing the
          # request in case the request was for user confirmation.
          req.session["user_newly_confirmed"] = true if req.path == "/users/confirmation"

          response
        end

        private

        def budgeting_redirect_for(request)
          process_id = request.session.delete(
            "active_combined_budgeting_process_id"
          )
          return unless process_id

          process = CombinedBudgeting::Process.find_by(id: process_id)
          redirect("/budgeting/#{process.slug}") if process && process.published?
        end

        # Mostly needed for development environments, otherwise the asset
        # requests would clear the session variable for the active combined
        # budgeting process. Letter opener is generally only used in
        # development.
        def direct_request?(request)
          request.path =~ %r{^/assets/.*$} || request.path =~ %r{^/letter_opener(/.*)?$}
        end

        # Checks if the budget redirect should be performed
        def budget_redirect_request?(request)
          request.path == "/authorizations" || request.session.delete("user_newly_confirmed")
        end

        def in_verification?(request)
          return true if request.path =~ %r{^/authorizations/new/?$}

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
