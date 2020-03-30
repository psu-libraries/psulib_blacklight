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

  before_action :flash_readonly, :flash_alert

  def blackcat_config
    @blackcat_config ||= BlackcatConfig::Builder.new
  end

  private

    def flash_readonly
      flash.now[:error] = blackcat_config.blackcat_message(:readonly) if blackcat_config.blackcat_message?(:readonly)
    end

    def flash_alert
      flash.now[:error] = blackcat_config.blackcat_message(:alert) if blackcat_config.blackcat_message?(:alert)
    end
end
