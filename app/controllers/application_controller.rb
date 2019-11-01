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

  helper_method :readonly?, :announcement_message

  before_action :readonly_message

  def readonly?
    (readonly_file? && readonly_status[:readonly]) || false
  end

  def announcement_message
    if readonly_file? && readonly_status.key?(:announcement)
      ActionController::Base.helpers.sanitize(readonly_status[:announcement])
    else
      ActionController::Base.helpers.sanitize(t('blacklight.announcement.html'))
    end
  end

  private

    def readonly_status
      HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config', 'readonly.yml')))
    end

    def readonly_file?
      File.file?(Rails.root.join('config', 'readonly.yml'))
    end

    def readonly_message
      flash.now[:error] = ActionController::Base.helpers.sanitize(readonly_status[:message]) if readonly?
    end
end
