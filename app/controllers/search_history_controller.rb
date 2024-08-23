# frozen_string_literal: true

class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  # TODO: Consider deleting the following line altogether. The following line was generated during an install.
  # Removing the line has zero effect on the display of constraints.
  helper RangeLimitHelper
end
