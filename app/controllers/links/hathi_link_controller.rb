# frozen_string_literal: true

require 'net/http'

module Links
  class HathiLinkController < ActionController::API
    def data
      render json: json_response
    end

    private

      def json_response
        JSON.parse(send_request)["items"].each do |item|
          return { itemUrl: item["itemURL"] }.to_json if item["usRightsString"] == "Full view"
        end
        { itmeUrl: nil }.to_json
      end

      def send_request
        Net::HTTP.get(uri)
      end

      def uri
        URI("https://catalog.hathitrust.org/api/volumes/brief/#{search_item}.json")
      end

      def search_item
        params['search_item']
      end
  end
end