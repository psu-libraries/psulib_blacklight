# frozen_string_literal: true

# Bento endpoint
class BentoController < CatalogController
  def index
    super

    respond_to do |format|
      format.html { render status: :unsupported_media_type }
      format.rss  { render status: :unsupported_media_type }
      format.atom { render status: :unsupported_media_type }
      format.json do
        @presenter = Blacklight::JsonPresenter.new(@response,
                                                   blacklight_config)
      end
    end
  end

  blacklight_config.configure do |config|
    config.add_facet_fields_to_solr_request = false
    config.add_index_field 'title_display_ssm', label: 'Title'
    config.default_solr_params = {
      facet: false
    }
  end

  private

    def enforce_bot_challenge
      # Challenge only if remote IP is not whitelisted
      ip_whitelist = ENV.fetch('BOT_CHALLENGE_IP_WHITELIST', '')
        .split(',')
        .map { |ip| IPAddr.new(ip.strip) unless ip.strip.empty? }
        .compact
      return if ip_whitelist.any? { |ip| ip.include?(IPAddr.new(request.remote_ip)) }

      super
    end
end
