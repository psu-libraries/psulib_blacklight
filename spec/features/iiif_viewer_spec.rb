# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'viewing a record', js: true, vcr: { record: :new_episodes } do
  context 'when the record does not have an IIIF manifest URL' do
    it 'does not render the Mirador viewer' do
      visit '/catalog/3500414'
      expect(page).not_to have_selector 'div[id="iiif-viewer"]'
    end
  end

  context 'when the record has an IIIF manifest URL' do
    it 'renders the Mirador viewer' do
      visit '/catalog/2025781'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
      within '#iiif-viewer' do
        expect(page).not_to have_content 'error'
      end
    end

    it 'does not show a link to the IIIF manifest file' do
      visit '/catalog/2025781'
      expect(page).not_to have_link 'IIIF manifest'
    end
  end

  context 'when the record has an ARK URL that redirects to the IIIF manifest' do
    it 'renders the Mirador viewer' do
      visit '/catalog/1267921'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
      within '#iiif-viewer' do
        expect(page).not_to have_content 'error'
      end
    end
  end

  context 'when the record has an IIIF manifest URL that returns a 500 error' do
    let(:r) { instance_double Faraday::Response, status: 500, headers: {} }

    before do
      allow(Faraday).to receive(:head)
        .with('https://arks.libraries.psu.edu/ark:/42409/ii34w27')
        .and_return r
    end

    it 'renders the Mirador viewer' do
      visit '/catalog/1267921'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
    end
  end

  context "when a failure occurs while trying to connect to the record's IIIF manifest URL" do
    before do
      allow(Faraday).to receive(:head)
        .with('https://arks.libraries.psu.edu/ark:/42409/ii34w27')
        .and_raise Faraday::ConnectionFailed.new(nil)
    end

    it 'renders the Mirador viewer' do
      visit '/catalog/1267921'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
    end
  end

  context "when a timeout occurs while trying to connect to the record's IIIF manifest URL" do
    before do
      allow(Faraday).to receive(:head)
        .with('https://arks.libraries.psu.edu/ark:/42409/ii34w27')
        .and_raise Faraday::TimeoutError
    end

    it 'renders the Mirador viewer' do
      visit '/catalog/1267921'
      expect(page).to have_selector 'div[id="iiif-viewer"]'
      expect(page).to have_selector 'main[class="Connect(WithPlugins(WorkspaceArea))-viewer-1 mirador-viewer"]'
    end
  end
end
