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
    fullpath = request.env.fetch('ORIGINAL_FULLPATH', '/')
    session[:redirect_url] ||= fullpath == '/login' ? '/' : fullpath
    session[:groups] = request.env.fetch(Settings.groups_header, '').split(',')
    redirect_to current_user ? session[:redirect_url] : '/login'
  end

  before_action do
    authorize_profiler
  end

  private

    def authorize_profiler
      return unless request.session.fetch(:groups, []).include?(Settings.admin_group)

      Rack::MiniProfiler.authorize_request
    end
end
