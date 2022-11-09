# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Announcement', type: :feature, js: true do
  context 'when hide_announcement is enabled' do
    before do
      Settings.add_source!(
        {
          hide_announcement: true,
          announcement: nil
        }
      )
      Settings.reload!
    end

    it 'does not display an announcement on top' do
      visit root_path
      expect(page).not_to have_css '.announcement'
    end
  end

  context 'when hide_announcement is disabled' do
    context 'without announcement settings' do
      before do
        Settings.add_source!(
          {
            hide_announcement: false,
            announcement: nil
          }
        )
        Settings.reload!
      end

      it 'displays the default announcement' do
        visit root_path
        expect(page).to have_css "div.announcement.#{I18n.t('blacklight.announcement.html_class')}"
      end
    end

    context 'with announcement settings' do
      before do
        Settings.add_source!(
          {
            hide_announcement: false,
            announcement: {
              html_class: 'bg-warning',
              message: 'Announcement Message',
              icon: 'fa-exclamation-circle'
            }
          }
        )
        Settings.reload!
      end

      it 'displays the given announcement' do
        visit root_path
        expect(page).to have_css 'div.announcement.bg-warning'
        expect(page).to have_css 'i.fa-exclamation-circle'
        expect(page).to have_content 'Announcement Message'
      end
    end
  end

  context 'without hide_announcement setting' do
    before do
      Settings.add_source!(
        {
          hide_announcement: nil,
          announcement: nil
        }
      )
      Settings.reload!
    end

    context 'without announcement settings' do
      it 'displays the default announcement' do
        visit root_path
        expect(page).to have_css "div.announcement.#{I18n.t('blacklight.announcement.html_class')}"
      end
    end

    context 'with announcement settings' do
      before do
        Settings.add_source!(
          {
            hide_announcement: nil,
            announcement: {
              html_class: 'bg-warning',
              message: 'Announcement Message',
              icon: 'fa-exclamation-circle'
            }
          }
        )
        Settings.reload!
      end

      it 'displays the given announcement' do
        visit root_path
        expect(page).to have_css 'div.announcement.bg-warning'
        expect(page).to have_css 'i.fa-exclamation-circle'
        expect(page).to have_content 'Announcement Message'
      end
    end
  end
end
