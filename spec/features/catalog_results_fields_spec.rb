# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CatalogResultsFields', type: :feature do
  describe 'Title fields' do
    it 'User does a search that returns at least one result without a vernacular title'
    # will have a sub-field titled \"Title:\" with the original, vernacular will be in the actual lead statement

    it 'User does a search that returns at least one result with a vernacular title'
    # no Title: subfield
    # some way of identifying the vernacular is indeed the title?

    it 'User does a search that returns one result with a uniform title'
    # will expect uniform title field to not be present

    it 'User does a search that returns one result with an additional title'
    # will expect additional field to not be present

    it 'User does a search that returns one result with a series title'
    # will expect series title field to not be present
  end
end
