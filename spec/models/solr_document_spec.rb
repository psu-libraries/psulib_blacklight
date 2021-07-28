# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  describe 'location_display' do
    it 'shows the correct text for a single location' do
      doc = described_class.new({ 'library_facet': ['Library 1'] })

      expect(doc.location_display).to eq 'Library 1'
    end

    it 'shows the correct text for 3 locations' do
      doc = described_class.new({ 'library_facet': ['Lib 1', 'Lib 2', 'Lib 3'] })

      expect(doc.location_display).to eq 'Lib 1 / Lib 2 / Lib 3'
    end

    it 'shows the correct text for 4 locations' do
      doc = described_class.new({ 'library_facet': ['1', '2', '3', '4'] })

      expect(doc.location_display).to eq 'Multiple Locations'
    end

    it 'returns nil if no library_facet is set' do
      doc = described_class.new({})

      expect(doc.location_display).to be_nil
    end
  end
end
