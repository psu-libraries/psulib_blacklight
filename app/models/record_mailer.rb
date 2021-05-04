# frozen_string_literal: true

# Only works for documents with a #to_marc right now.
class RecordMailer < ApplicationMailer
  def email_record(documents, details, url_gen_params)
    title = begin
      documents.first.to_semantic_values[:title].first
    rescue StandardError
      I18n.t('blacklight.email.text.default_title')
    end
    subject = I18n.t('blacklight.email.text.subject', count: documents.length, title: title)

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(to: details[:to], subject: subject)
  end

  def email_report_issue(title:, record_number:, comment:, email: '')
    @title = title
    @record_number = record_number
    @comment = comment
    @email = email

    mail(to: Settings.report_issue_email_recipient, subject: t('blackcat.report_issue.email.subject'))
  end

  def sms_record(documents, details, url_gen_params)
    @documents      = documents
    @url_gen_params = url_gen_params
    mail(to: details[:to], subject: '')
  end
end
