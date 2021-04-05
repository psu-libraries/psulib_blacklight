# frozen_string_literal: true

require 'net/http'

module Availability
  class AvailabilityController < ActionController::API
    def sirsi_data
      title_ids = params[:title_ids].join('&titleID=')

      sirsi_uri = URI(Settings.sirsi_url + title_ids)

      sirsi_response = Net::HTTP.get(sirsi_uri)

      render xml: sirsi_response
    end
  end
end
