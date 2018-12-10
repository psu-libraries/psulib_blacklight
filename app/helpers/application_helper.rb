# frozen_string_literal: true

module ApplicationHelper
  # Makes a link to the item's bound in title. Could be refactored later to be more generic.
  def link_it(options = {})
    options[:value] # the value of the field
    field_data = options[:value].first
    field_data = JSON.parse field_data

    link_to field_data['boundtitle'], "/catalog/#{field_data['boundcatkey']}"
  end
end
