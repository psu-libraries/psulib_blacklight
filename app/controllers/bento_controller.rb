# frozen_string_literal: true

# Bento endpoint
class BentoController < CatalogController
  skip_before_action :enforce_bot_challenge, only: :index

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
end
