# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClauseCountLimiter, type: :helper do
  def count_search_terms(term_string)
    term_string.split.length
  end
  context 'when searching all fields' do
    let(:blacklight_params) { { 'search_field' => 'all_fields', q: 'one' } }

    it 'limits to 10 terms' do
      solr_parameters = { q: 'one two three four five six seven eight nine ten eleven twelve thirteen' }
      limit_clause_count(solr_parameters)
      expect(solr_parameters[:q]).to eq 'one two three four five six seven eight nine ten'
    end
  end

  context 'when searching author' do
    let(:blacklight_params) { { 'search_field' => 'author', q: 'one' } }

    it 'limits terms to 36' do
      solr_parameters = { q: 'Bork ' * 40 }
      limit_clause_count(solr_parameters)
      expect(count_search_terms(solr_parameters[:q])).to eq(36)
    end
  end

  context 'when searching title' do
    let(:blacklight_params) { { 'search_field' => 'title', q: 'one' } }

    it 'limits terms to 36' do
      solr_parameters = { q: 'Meee ' * 40 }
      limit_clause_count(solr_parameters)
      expect(count_search_terms(solr_parameters[:q])).to eq(36)
    end
  end

  context 'when searching subject' do
    let(:blacklight_params) { { 'search_field' => 'subject', q: 'one' } }

    it 'limits terms to 15' do
      solr_parameters = { q: 'Wakka ' * 40 }
      limit_clause_count(solr_parameters)
      expect(count_search_terms(solr_parameters[:q])).to eq(15)
    end
  end

  context 'when searching isbn' do
    let(:blacklight_params) { { 'search_field' => 'isbn_issn', q: 'one' } }

    it 'limits terms to 15' do
      solr_parameters = { q: 'Bwawk ' * 40 }
      limit_clause_count(solr_parameters)
      expect(count_search_terms(solr_parameters[:q])).to eq(15)
    end
  end

  context 'when searching all other fields' do
    let(:blacklight_params) { { 'search_field' => 'publisher', q: 'one' } }

    it 'limits terms to 21' do
      solr_parameters = { q: 'Okay ' * 40 }
      limit_clause_count(solr_parameters)
      expect(count_search_terms(solr_parameters[:q])).to eq(20)
    end
  end
end
