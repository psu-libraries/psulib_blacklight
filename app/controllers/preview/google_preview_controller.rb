# frozen_string_literal: true

require 'net/http'

module Preview
  class GooglePreviewController < ActionController::API
    def data
      render json: json_response
    end

    private

      def json_response
        JSON.parse(send_request.gsub('var _GBSBookInfo = ', '')[0..-2])
      end

      def send_request
        Net::HTTP.get(uri)
      end

      def uri
        URI("https://books.google.com/books?jscmd=viewapi&bibkeys=#{search_item}")
      end

      def search_item
        params['search_item']
      end
  end
end
