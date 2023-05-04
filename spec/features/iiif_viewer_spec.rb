# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'viewing a record', :vcr, type: :feature, js: true do
  context 'when the record does not have an IIIF manifest' do
    it 'does not render the Mirador viewer' do
      visit '/catalog/3500414'
      expect(page).not_to have_selector 'div[id="iiif-viewer"]'
    end
  end

  context 'when the record has a IIIF manifest' do
    it 'renders the Mirador viewer' do
      visit '/catalog/2025781'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
    end
  end
end
