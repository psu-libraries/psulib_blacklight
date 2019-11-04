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

  helper_method :blackcat_message?, :blackcat_message

  before_action :flash_readonly

  def blackcat_message?(arg)
    (message_file? && message_status[arg]) || false
  end

  def blackcat_message(arg)
    # Falls back to blacklight.en.yml for announcement if not defined
    message = if arg == :announcement && !blackcat_message?(arg)
                t('blacklight.announcement.html')
              else
                message_status[arg]
              end
    ActionController::Base.helpers.sanitize(message)
  end

  private

    def message_status
      HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config', 'blackcat_messages.yml')))
    end

    def message_file?
      File.file?(Rails.root.join('config', 'blackcat_messages.yml'))
    end

    def flash_readonly
      flash.now[:error] = blackcat_message(:readonly) if blackcat_message?(:readonly)
    end
end
