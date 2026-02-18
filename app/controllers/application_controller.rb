# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  before_action :attempt_passive_authentication
  layout 'blacklight'

  protect_from_forgery with: :exception

  # Rails 5.1 and above requires permitted params to be defined in the Controller
  # BL doesn't do that, but might in the future. This allows us to use the pre 5.1
  # behavior until we can define all possible param  in the future.
  ActionController::Parameters.permit_all_parameters = true

  helper_method :blackcat_config

  def login
    session[:groups] = request.env.fetch(Settings.groups_header, '').split(',')
    redirect_location = params['fullpath'] || stored_location_for(User) || '/'
    if current_user
      flash[:success] = I18n.t('blackcat.successful_login')
      if params['bookmark_doc_id']
        redirect_to controller: 'bookmarks', action: 'initialize_bookmark',
                    id: params['bookmark_doc_id'], redirect_location: redirect_location and return
      end

      redirect_to redirect_location
    else
      redirect_to login_path
    end
  end

  before_action do
    authorize_profiler
  end

  private

    def authorize_profiler
      return unless request.session.fetch(:groups, []).include?(Settings.admin_group)

      Rack::MiniProfiler.authorize_request
    end

    def attempt_passive_authentication
      return if user_signed_in?

      warden.authenticate(scope: :user)
    end
end
