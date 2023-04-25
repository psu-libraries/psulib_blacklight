# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreferredCallNumber do
  let(:solr_doc) { SolrDocument.new(source_doc) }

  context 'when there is one LC call number' do
    let(:source_doc) { { call_number_lc_ssm: ['ABC'] } }

    it 'returns LC call number' do
      expect(solr_doc.preferred_call_number).to eq ['ABC']
      expect(solr_doc.preferred_classification).to eq 'lc'
    end
  end

  context 'when there are multiple LC call numbers' do
    let(:source_doc) { { call_number_lc_ssm: ['ABC', 'DEF'] } }

    it 'returns LC call numbers' do
      expect(solr_doc.preferred_call_number).to eq ['ABC', 'DEF']
      expect(solr_doc.preferred_classification).to eq 'lc'
    end
  end

  context 'when there is one Dewey call number' do
    let(:source_doc) { { call_number_dewey_ssm: ['131'] } }

    it 'returns Dewey call number' do
      expect(solr_doc.preferred_call_number).to eq ['131']
      expect(solr_doc.preferred_classification).to eq 'dewey'
    end
  end

  context 'when there are multiple Dewey call numbera' do
    let(:source_doc) { { call_number_dewey_ssm: ['131', '132'] } }

    it 'returns Dewey call numbers' do
      expect(solr_doc.preferred_call_number).to eq ['131', '132']
      expect(solr_doc.preferred_classification).to eq 'dewey'
    end
  end

  context 'when there are both LC and Dewey call numbers' do
    let(:source_doc) { { call_number_lc_ssm: ['ABC', 'DEF'], call_number_dewey_ssm: ['131'] } }

    it 'returns LC call number' do
      expect(solr_doc.preferred_call_number).to eq ['ABC', 'DEF']
      expect(solr_doc.preferred_classification).to eq 'lc'
    end
  end
end
