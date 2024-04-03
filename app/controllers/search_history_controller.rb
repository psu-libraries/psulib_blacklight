# frozen_string_literal: true

class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  # TODO: Consider deleting the following two lines altogether. The following lines were generated during an install.
  # Removing these lines has zero effect on the display of constraints.
  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper RangeLimitHelper
end
