class AvailabilityController < ApplicationController
  def index
    render json: JSON.parse(File.read('config/locations.json')), layout: false
  end
end