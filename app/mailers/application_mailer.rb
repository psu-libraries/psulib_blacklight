# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@psu.edu'
  layout 'mailer'
end
