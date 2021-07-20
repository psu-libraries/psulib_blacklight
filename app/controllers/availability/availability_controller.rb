# frozen_string_literal: true

require 'net/http'

module Availability
  class AvailabilityController < ActionController::API
    def sirsi_data
      args = "&includeBoundTogether=true&titleID=#{params[:title_ids].join('&titleID=')}"

      make_sirsi_request(args)
    end

    def sirsi_item_data
      args = "&itemID=#{params[:item_ids].join('&itemID=')}"

      make_sirsi_request(args)
    end

    private

      def make_sirsi_request(args)
        sirsi_uri = URI(Settings.sirsi_url + args)

        sirsi_response = Net::HTTP.get(sirsi_uri)

        render xml: sirsi_response
      end
  end
end
