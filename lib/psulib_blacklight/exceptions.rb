# frozen_string_literal: true

class SolrCollectionsNotFoundError < StandardError
  def initialize(msg = 'No collections are found.')
    super
  end
end
