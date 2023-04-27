# frozen_string_literal: true

require 'net/http'

module Availability
  class AvailabilityController < ActionController::API
    def sirsi_data
      args = "&includeBoundTogether=true&titleID=#{params[:title_ids].join('&titleID=')}"

      render xml: HoldingsRequestService.new(args).make_holdings_request
    end

    def sirsi_item_data
      args = "&itemID=#{params[:item_ids].join('&itemID=')}"

      render xml: HoldingsRequestService.new(args).make_holdings_request
    end
  end
end
