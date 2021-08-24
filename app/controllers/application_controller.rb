# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  protect_from_forgery with: :exception

  # Rails 5.1 and above requires permitted params to be defined in the Controller
  # BL doesn't do that, but might in the future. This allows us to use the pre 5.1
  # behavior until we can define all possible param  in the future.
  ActionController::Parameters.permit_all_parameters = true

  helper_method :blackcat_config

  before_action do
    authorize_profiler
  end

  private

    # @note The Matomo ID is used to capture statistics from our production instance. This is very unlikely to change.
    # We can use this method to limit profiling to only dev and preview instances until we can implement a way to limit
    # it to particular users and UMGs.
    def authorize_profiler
      return if Settings.matomo_id.to_i == 7

      Rack::MiniProfiler.authorize_request
    end
end
