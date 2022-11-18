# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search Results', type: :feature do
  describe 'search result page', js: true do
    before do
      #visit most general results page
    end

    it 'displays appropriate headers and constraints' do
      #expect header
      #expect container header
      #expect constraints
    end

    context 'when there are results to display' do
      it 'displays results content' do
        #expect render documents index
        #expect not to have zero results render
      end
    end 

    context 'when there are no results to display' do
      before do
        #visit search result for kinesiology
      end

      it 'displays content for "no results found"' do
        #expect render for zero results
        #expect not to have render_documents_index
      end
    end
  end
end
