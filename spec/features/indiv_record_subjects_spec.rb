# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Individual Record Subjects', type: :feature do
  describe 'Individual record subject links', js: true do
    before do
      #visit individual record
    end

    it 'displays the subjects for a given record' do
      #expect list of subjects
    end

    context 'when users want to search for the first term of a given subject' do
      before do
        #click term for first level of hierarchy
      end

      it 'takes them to a search result of the first term of a given subject' do
        #expect appropriate result for just first search term (either by content or by number of results? or both?)
        #expect not to have result that would only pop for later terms?
      end
    end

    context 'when users want to search for the second term of a given subject' do
      before do
        #click term for second level of hierarchy
      end
  
      it 'takes them to a search result of the second term of a given subject' do
        #expect appropriate result for second search term
        #expect not to have result that would only pop for later terms?
      end
    end

    context 'when users want to search for the full term of a given subject' do
      before do
        #click term for first level of hierarchy
      end
  
      it 'takes them to a search result of the full term of a given subject' do
        #expect appropriate result for full search term
      end
    end
  end
end
