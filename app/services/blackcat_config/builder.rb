# frozen_string_literal: true

# Responsible for building blackcat config
class BlackcatConfig::Builder
  def initialize
    @config = config_load
  end

  def readonly_holds?
    (config_file? && @config[:readonly_holds]) || false
  end

  def blackcat_message?(arg)
    (config_file? && @config[arg].present?) || I18n.exists?("blacklight.#{arg}", :en)
  end

  def blackcat_message(arg)
    message = if config_file? && @config[arg]
                @config[arg]
              else
                I18n.t("blacklight.#{arg}.html")
              end

    ActionController::Base.helpers.sanitize message
  end

  private

    def config_load
      return nil unless config_file?

      HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config', 'blackcat_messages.yml')))
    end

    def config_file?
      File.file?(Rails.root.join('config', 'blackcat_messages.yml'))
    end
end
