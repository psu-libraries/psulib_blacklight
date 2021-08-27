# frozen_string_literal: true

class CatalogAdmin
  def self.matches?(request)
    current_user = request.env['warden'].user
    return false if current_user.blank?

    request.session.fetch(:groups, []).include?(Settings.admin_group)
  end
end
