# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RecordPageFields', type: :feature do
  describe 'Title fields' do
    scenario 'User visits a document with a vernacular title' do
      pending 'Run these once the vernacular title feature is being worked on'
      # Vernacular title field will be displayed as title, title will appear below with label title')
      # TODO: pluralize label
      visit '/catalog/2788022'
      expect(page).to have_selector 'h1', count: 1
      expect(page).to have_selector 'h1', text: '小說ワンダフルライフ'
      expect(page).to have_selector 'dt.blacklight-title_display_ssm', text: 'Title:', count: 1
      expect(page).to have_selector 'dd.blacklight-title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-title_display_ssm',
                                    text: 'Shōsetsu wandafuru raifu', count: 1
    end

    scenario 'User visits a document without a vernacular title' do
      # Title field will be displayed as title
      visit '/catalog/2431513'
      expect(page).to have_selector 'h1', count: 1
      expect(page).to have_selector 'h1', text: 'La ressemblance'
    end

    scenario 'User visits a document with a uniform title' do
      # Uniform title field will be displayed
      # TODO: pluralize label
      visit '/catalog/286971'
      expect(page).to have_selector 'dt.blacklight-uniform_title_display_ssm',
                                    text: 'Uniform Title:', count: 1
      expect(page).to have_selector 'dd.blacklight-uniform_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-uniform_title_display_ssm',
                                    text: 'Adamo ed Eva', count: 1
    end

    scenario 'User visits a document with additional titles' do
      pending 'Run these once the additional title feature is being worked on'
      # Additional title field will be displayed
      # TODO: pluralize label
      additional_title_example = 'Fleurs du mal (Les) / Hungarian Fantasy / In the Jungle (Tabery, Redik, Recreation -'\
                                 ' Graz Grosses Orchester, Swierczewski)'
      visit '/catalog/21835545'
      expect(page).to have_selector 'dt.blacklight-additional_title_display_ssm',
                                    text: 'Additional Title:', count: 1
      expect(page).to have_selector 'dd.blacklight-additional_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-additional_title_display_ssm',
                                    text: additional_title_example, count: 1
    end

    scenario 'User visits a document with a series title' do
      pending 'Run these once the series title feature is being worked on'
      # Series title field will be displayed
      # TODO: pluralize label
      visit '/catalog/1618709'
      expect(page).to have_selector 'dt.blacklight-series_title_display_ssm',
                                    text: 'Series Title:', count: 1
      expect(page).to have_selector 'dd.blacklight-series_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-series_title_display_ssm',
                                    text: 'Acappella artists', count: 1
    end
  end
end
