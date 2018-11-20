require 'rails_helper'

RSpec.feature "CatalogResultsFields", type: :feature do

  feature "Title fields" do
    scenario "User does a search that returns at least one result without a vernacular title" do
      # will have a sub-field titled "Title:" with the original, vernacular will be in the actual lead statment
    end

    scenario "User does a search that returns at least one result with a vernacular title" do
      # no Title: subfield
      # some way of identifying the vernacular is indeed the title?
    end

    scenario "User does a search that returns one result with a uniform title" do
      # will expect this field to not be present
    end

    scenario "User does a search that returns one result with an additional title" do
      # will expect this field to not be present
    end

    scenario "User does a search that returns one result with a series title" do
      # will expect this field to not be present
    end
  end

end
