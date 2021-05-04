# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordMailer do
  before do
    allow(described_class).to receive(:default).and_return(from: 'no-reply@libraries.psu.edu')
  end

  describe 'report_issue' do
    before do
      @email = described_class.email_report_issue(title: 'My Book',
                                                  record_number: 123,
                                                  comment: 'Some comments',
                                                  email: 'test@test.com')
    end

    it 'receives the TO paramater and send the email to that address' do
      expect(@email.to).to include 'test@test.com'
    end

    it 'has the correct subject' do
      expect(@email.subject).to match /Penn State University Libraries Catalog - Issue Report/
    end

    it 'has the correct from address (w/o the port number)' do
      expect(@email.from).to include 'no-reply@libraries.psu.edu'
    end

    it 'prints out the correct body' do
      expect(@email.body).to match /Penn State University Libraries Catalog - Issue Report/
      expect(@email.body).to match /Title: My Book/
      expect(@email.body).to match /Record Number: 123/
      expect(@email.body).to match /Record URL: https:\/\/catalog.libraries.psu.edu\/catalog\/123/
      expect(@email.body).to match /Email Address: test@test.com/
    end

    context 'when the email field is not provided' do
      email = described_class.email_report_issue(title: 'My Book',
                                                 record_number: 123,
                                                 comment: 'Some comments')

      it 'does not contain an email field in the body' do
        expect(email.body).not_to match /Email Address:/
      end
    end
  end
end
