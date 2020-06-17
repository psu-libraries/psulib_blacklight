# frozen_string_literal: true

# Add some configurable field sets to Blacklight's Configuration class
module Blacklight
  class Configuration
    define_field_access :home_facet_field
  end
end
