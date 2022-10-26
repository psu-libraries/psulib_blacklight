# frozen_string_literal: true

class AdminUser
  def self.matches?(request)
    return true if request.session.fetch(:groups, []).include?(Settings.admin_group)

    false
  end
end
