# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page not found', type: :routing do
  it 'routes to page not found if path is completely invalid' do
    expect(get: 'kaljhgl').to route_to controller: 'errors', action: 'not_found', catch_unknown_routes: 'kaljhgl'
  end
end
