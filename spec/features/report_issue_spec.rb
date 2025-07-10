# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Report Issue Form', :js do
  describe 'when a comment is included' do
    it 'submits the report issue form successfully and sends an email' do
      visit '/catalog/19437'
      click_on 'Report an Issue'

      fill_in 'comment', with: 'There is an issue with this record.'
      fill_in 'email', with: 'user@example.com'
      click_button I18n.t('blacklight.sms.form.submit')

      expect(page).to have_content(I18n.t('blacklight.email.success'))
      mail = ActionMailer::Base.deliveries.last
      expect(mail).to be_present
      expect(mail.subject).to include('Penn State University Libraries Catalog - Issue Report')
      expect(mail.body.encoded).to include('There is an issue with this record.')
      expect(mail.body.encoded).to include('user@example.com')
      expect(mail.body.encoded).to include('/catalog/19437')
      expect(mail.body.encoded).to include('Title: The theory of wages')
    end
  end

  describe 'when a comment is not included' do
    it 'does not submit form or send an email' do
      visit '/catalog/19437'
      click_on 'Report an Issue'

      fill_in 'comment', with: ''
      fill_in 'email', with: 'user@example.com'
      click_button I18n.t('blacklight.sms.form.submit')

      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
