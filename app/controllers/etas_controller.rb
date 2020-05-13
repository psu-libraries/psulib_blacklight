# frozen_string_literal: true

class EtasController < ApplicationController
  def show
    render json: etas_links
  end

  private

    def etas_links
      return {} unless etas_fulltext_item? hathitrust_response_hash

      etas_url = hathitrust_etas_url(hathitrust_response_hash)

      render_etas_partial_to_string(etas_url).to_json
    end

    def render_etas_partial_to_string(etas_url)
      render_to_string('hathitrust/etas',
                       locals: { etas_blackcat_url_hash: etas_blackcat_url_hash(etas_url) },
                       layout: false)
    end

    def etas_blackcat_url_hash(etas_url)
      { href: "#{etas_url}?urlappend=%3Bsignon=swle:urn:mace:incommon:psu.edu",
        text: I18n.t('blackcat.links.hathitrust') }
    end

    def etas_fulltext_item?(hathi_hash)
      hathi_hash.fetch('items', [])
        .select { |i| i.fetch('usRightsString') == 'Limited (search-only)' }
        .any?
    end

    def hathitrust_etas_url(hathi_hash)
      hathi_hash.fetch('items').first.fetch('itemURL')
    end

    def hathitrust_response_hash
      @hathitrust_response_hash ||= JSON.parse hathitrust_api_response
    end

    # rubocop:disable MethodLength
    def hathitrust_api_response
      response = Net::HTTP.start(hathitrust_uri.host,
                                 hathitrust_uri.port,
                                 open_timeout: 10,
                                 read_timeout: 10,
                                 use_ssl: hathitrust_uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new hathitrust_uri
        http.request request
      end
      response.body
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      '{}'
    end
    # rubocop:enable MethodLength

    def hathitrust_uri
      @hathitrust_uri ||= URI(hathitrust_uri_path)
    end

    def hathitrust_uri_path
      [hathitrust_base_uri,
       'api',
       'volumes',
       'brief',
       'oclc',
       "#{params[:id]}.json"].join('/')
    end

    def hathitrust_base_uri
      'https://catalog.hathitrust.org'
    end
end
