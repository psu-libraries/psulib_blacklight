# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CatalogResultsFields', type: :feature do
  describe 'Title fields' do
    it 'User does a search that returns at least one result without a vernacular title' do
      pending('will have a sub-field titled \"Title:\" with the original, vernacular will be in the actual lead
              statement')
    end

    it 'User does a search that returns at least one result with a vernacular title' do
      # no Title: subfield
      pending('some way of identifying the vernacular is indeed the title?')
    end

    it 'User does a search that returns one result with a uniform title' do
      pending('will expect uniform title field to not be present')
    end

    it 'User does a search that returns one result with an additional title' do
      pending('will expect additional field to not be present')
    end

    it 'User does a search that returns one result with a series title' do
      pending('will expect series title field to not be present')
    end
  end
end
