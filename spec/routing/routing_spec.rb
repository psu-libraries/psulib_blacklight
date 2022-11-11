# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Error Routing', type: :routing do
  it 'routes to page not found if path is completely invalid' do
    expect(get: 'kaljhgl').to route_to controller: 'errors', action: 'not_found', catch_unknown_routes: 'kaljhgl'
  end

  it 'routes to internal server error if directed to the 500 path' do
    expect(get: '/500').to route_to controller: 'errors', action: 'internal_server_error'
  end
end
