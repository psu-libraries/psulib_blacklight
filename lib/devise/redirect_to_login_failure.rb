# frozen_string_literal: true

class RedirectToLoginFailure < Devise::FailureApp
  def redirect_url
    '/login'
  end
end
