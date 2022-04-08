# frozen_string_literal: true

require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class HttpHeaderAuthenticatable < Authenticatable
      def authenticate!
        http_user = remote_user(request.headers)
        return fail! if http_user.blank?

        session.delete(:guest_user_id)

        user = User.find_or_create_by(email: http_user)
        success!(user)
      end

      def valid?
        remote_user(request.headers).present?
      end

      def remote_user(headers)
        headers.fetch(Settings.user_header, nil)
      end
    end
  end
end

Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
