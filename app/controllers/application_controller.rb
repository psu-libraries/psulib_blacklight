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

  def login
    session[:redirect_url] = home_or_original_path
    session[:groups] = request.env.fetch(Settings.groups_header, '').split(',')
    if current_user
      redirect_to session[:redirect_url]
    else
      redirect_to login_path
    end
  end

  before_action do
    authorize_profiler
  end

  private

    def home_or_original_path
      request.env.fetch('ORIGINAL_FULLPATH', '/')
    end

    def authorize_profiler
      return unless request.session.fetch(:groups, []).include?(Settings.admin_group)

      Rack::MiniProfiler.authorize_request
    end
end
