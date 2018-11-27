# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RecordPageFields', type: :feature do
  let (:documents) {
    fixtures_doc = File.read("#{fixture_path}/current_fixtures.json")
    JSON.parse(fixtures_doc)
  }

  feature 'Vernacular titles' do
    let (:doc_vern) { documents.find { |i| i['id'] == '2788022' } }
    let (:doc_no_vern) { documents.find { |i| i['id'] == '2431513' } }

    scenario 'User visits a document with a vernacular title' do
      # Vernacular title field will be displayed as title, title will appear below with label title')
      visit "/catalog/#{doc_vern['id']}"
      expect(page).to have_selector 'h1', count: 1
      expect(page).to have_selector 'h1', text: (doc_vern['title_display_ssm'][0]).to_s
      expect(page).to have_selector 'dd.blacklight-title_latin_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-title_latin_display_ssm',
                                    text: (doc_vern['title_latin_display_ssm'][0]).to_s, count: 1
    end

    scenario 'User visits a document without a vernacular title' do
      # Title field will be displayed as title
      visit "/catalog/#{doc_no_vern['id']}"
      expect(page).to have_selector 'h1', count: 1
      expect(page).to have_selector 'h1', text: (doc_no_vern['title_display_ssm'][0]).to_s
    end
  end

  feature 'Uniform title' do
    let (:doc_uni) { documents.find { |i| i['id'] == '286971' } }

    scenario 'User visits a document with a uniform title' do
      # Uniform title field will be displayed
      visit "/catalog/#{doc_uni['id']}"
      expect(page).to have_selector 'dd.blacklight-uniform_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-uniform_title_display_ssm',
                                    text: (doc_uni['uniform_title_display_ssm'][0]).to_s, count: 1
    end
  end

  feature 'Additional titles' do
    let (:doc_addl) { documents.find { |i| i['id'] == '21835545' } }

    scenario 'User visits a document with additional titles' do
      # Additional title field will be displayed
      visit "/catalog/#{doc_addl['id']}"
      expect(page).to have_selector 'dd.blacklight-additional_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-additional_title_display_ssm',
                                    text: (doc_addl['additional_title_display_ssm'][0]).to_s, count: 1
    end
  end

  feature 'Series title' do
    let (:doc_series) { documents.find { |i| i['id'] == '1618709' } }

    scenario 'User visits a document with a series title' do
      # Series title field will be displayed
      visit "/catalog/#{doc_series['id']}"
      expect(page).to have_selector 'dd.blacklight-series_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-series_title_display_ssm',
                                    text: (doc_series['series_title_display_ssm'][0]).to_s, count: 1
    end
  end

  feature 'Series title' do
    let (:doc_related) { documents.find { |i| i['id'] == '13217672' } }

    scenario 'User visits a document with a related title' do
      # Series title field will be displayed
      visit "/catalog/#{doc_related['id']}"
      expect(page).to have_selector 'dd.blacklight-related_title_display_ssm', count: 1
      expect(page).to have_selector 'dd.blacklight-related_title_display_ssm',
                                    text: (doc_related['related_title_display_ssm'][0]).to_s, count: 1
    end
  end
end
