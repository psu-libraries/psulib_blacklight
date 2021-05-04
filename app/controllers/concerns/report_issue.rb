# frozen_string_literal: true

module ReportIssue
  extend ActiveSupport::Concern

  private

    def report_issue_action(_documents)
      mail = RecordMailer.email_report_issue(title: params[:title],
                                             record_number: params[:record_number],
                                             comment: params[:comment],
                                             email: params[:email])

      if mail.respond_to? :deliver_now
        mail.deliver_now
      else
        mail.deliver
      end

      flash[:success] = t('blacklight.email.success')
    end

    def validate_report_issue_params
      if params[:comment].blank?
        flash[:error] = t('blackcat.report_issue.errors.comment')
      end

      flash[:error].blank?
    end
end
