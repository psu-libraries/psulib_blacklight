# frozen_string_literal: true

require 'devise/strategies/http_header_authenticatable'

module Devise
  module Models
    module HttpHeaderAuthenticatable
      extend ActiveSupport::Concern
    end
  end
end
