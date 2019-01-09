# frozen_string_literal: true

module ApplicationHelper
  # Makes a link to a catalog item.
  def catalog_link(options = {})
    field_data = options[:value].first
    field_data = JSON.parse field_data

    link_to field_data['linktext'], "/catalog/#{field_data['catkey']}"
  end

  # Turns NNNNNN into HH:MM:SS, attached to duration_ssm
  def display_duration(options = {})
    options[:value]&.map { |v| v.scan(/([0-9]{2})/).join(':') }
  end
end
